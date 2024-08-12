import Foundation

enum ThirdPartyOTPAuthenticationMethod {
  case thirdPartyOTP(String)
  case duoPushToken(String)

  var parameterKey: String {
    switch self {
    case .thirdPartyOTP:
      return "otp"
    case .duoPushToken:
      return "duoToken"
    }
  }

  var parameterValue: String {
    switch self {
    case let .thirdPartyOTP(otpCode):
      return otpCode
    case let .duoPushToken(token):
      return token
    }
  }
}
