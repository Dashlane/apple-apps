import CoreTypes
import DashlaneAPI
import Foundation

public typealias LoginResponse = AppAPIClient.Authentication.GetAuthenticationMethodsForLogin
  .Response
public typealias SSOInfo = AuthenticationSsoInfo

extension Array where Element == AuthenticationMethodsVerifications {
  public func loginMethod(for login: Login) -> LoginMethod? {
    let types = self.map { $0.type }
    if types.contains(.emailToken) {
      return .tokenByEmail()
    } else if types.contains(.duoPush) {
      return .thirdPartyOTP(.duoPush)
    } else if types.contains(.totp) {
      return .thirdPartyOTP(.totp)
    } else if types.contains(.sso) {
      guard let string = ssoInfo?.serviceProviderUrl,
        let url = URL(string: "\(string)?redirect=mobile&username=\(login.email)&frag=true"),
        url.scheme != nil
      else {
        return nil
      }
      return .loginViaSSO(
        SSOAuthenticationInfo(
          login: login, serviceProviderUrl: url, isNitroProvider: ssoInfo?.isNitroProvider ?? false,
          migration: ssoInfo?.migration))
    }
    return nil
  }

  public var isOTP1Enabled: Bool {
    let types = self.map { $0.type }
    if types.contains(.duoPush) || types.contains(.totp) {
      return true
    } else {
      return false
    }
  }

  public var ssoInfo: AuthenticationSsoInfo? {
    self.filter({ $0.type == .sso }).first?.ssoInfo
  }
}

extension LoginMethod {
  public var otpOption: ThirdPartyOTPOption? {
    switch self {
    case .thirdPartyOTP(let option, _):
      return option
    default:
      return nil
    }
  }
}

extension LoginResponse {
  public var userAccountType: AccountType {
    get throws {
      guard verifications.ssoInfo == nil else {
        return .sso
      }
      switch accountType {
      case .masterPassword:
        return .masterPassword
      case .invisibleMasterPassword:
        return .invisibleMasterPassword
      case .securityKey, .undecodable:
        throw UndecodableCaseError(AuthenticationMethodsAccountType.self)
      }
    }
  }
}
