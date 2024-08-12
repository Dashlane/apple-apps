import CoreSession
import Foundation

extension SecureLockMode {
  var shouldShowConvenientAuthenticationMethod: Bool {
    switch self {
    case .masterKey:
      return false
    case let .pincode(lock):
      return !lock.attempts.tooManyAttempts
    case let .biometryAndPincode(_, lock):
      return !lock.attempts.tooManyAttempts
    default:
      return true
    }
  }
}
