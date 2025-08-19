import CoreSession
import CoreTypes
import Foundation

protocol AccountInfo: Codable {
  var email: String { get }
  var loginType: AccountLoginType { get }
  var subtitle: String? { get }
}

enum AccountLoginType: Codable {
  enum OTP: Codable {
    case otp1
    case otp2
    case duoPush
  }

  case masterPassword
  case sso
  case otp(type: OTP)
}

extension SessionsContainerProtocol {
  func localAccounts() throws -> [LocalAccount] {
    try localAccountsInfo().map { (login, sessionInfo) in
      LocalAccount(email: login.email, loginType: sessionInfo?.loginType ?? .masterPassword)
    }
  }
}

struct LocalAccount: LoginKit.AccountInfo {
  let email: String
  let loginType: AccountLoginType

  var subtitle: String? {
    loginType.subtitle
  }
}

extension SessionInfo {
  fileprivate var loginType: AccountLoginType {
    if self.accountType == .sso {
      return .sso
    } else if self.loginOTPOption == .duoPush {
      return .otp(type: .duoPush)
    } else if self.loginOTPOption == .totp {
      return .otp(type: .otp2)
    }
    return .masterPassword
  }
}
