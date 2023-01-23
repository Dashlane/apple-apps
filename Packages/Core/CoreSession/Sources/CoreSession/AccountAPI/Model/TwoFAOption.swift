import Foundation

public struct TwoFAStatus: Decodable {
    public let type: TwoFAOption
}

public enum TwoFAOption: String, Decodable, Hashable {
    case emailToken = "email_token"
    case totpForFirstLogin = "totp_device_registration"
    case totpForEveryLogin = "totp_login"
    case sso
}

public enum Dashlane2FAType: String, Identifiable, Hashable {
    public var id: String {
        return rawValue
    }
    case otp1
    case otp2
}

public extension TwoFAStatus {
    var twoFAType: Dashlane2FAType? {
        switch type {
        case .totpForEveryLogin:
            return .otp2
        case .totpForFirstLogin:
            return .otp1
        default:
            return nil
        }
    }
}
