import Foundation

public enum UnregisteredDeviceAuthentication {
    case token(String)
    case thirdPartyOTP(String)
    case duoPushToken(String)

    var parameterKey: String {
        switch self {
        case .token:
            return "token"
        case .thirdPartyOTP:
            return "otp"
        case .duoPushToken:
            return "duoToken"
        }
    }

    var parameterValue: String {
        switch self {
        case let .token(token):
            return token
        case let .thirdPartyOTP(otpCode):
            return otpCode
        case let .duoPushToken(token):
            return token
        }
    }
}
