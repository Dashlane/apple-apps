import Foundation
import CoreSession

extension SecureLockMode {
    var shouldShowConvenientAuthenticationMethod: Bool {
        switch self {
        case .masterKey:
            return false
        case let .pincode(_, attempts, _):
            return !attempts.tooManyAttempts
        case let .biometryAndPincode(_,_, attempts, _):
            return !attempts.tooManyAttempts
        default:
            return true
        }
    }
}
