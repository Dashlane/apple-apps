import Foundation
import DashlaneAPI

public enum Dashlane2FAType: String, Identifiable, Hashable {
    public var id: String {
        return rawValue
    }
    case otp1
    case otp2
}

public extension AuthenticationGet2FAStatusType {
    var twoFAType: Dashlane2FAType? {
        switch self {
        case .totpLogin:
            return .otp2
        case .totpDeviceRegistration:
            return .otp1
        default:
            return nil
        }
    }
}
