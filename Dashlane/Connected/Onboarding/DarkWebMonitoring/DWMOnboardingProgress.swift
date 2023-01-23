import Foundation
import CoreSettings
import DashlaneAppKit

enum DWMOnboardingProgress: Int, CaseIterable, DataConvertible, Comparable {
    case shown
    case emailRegistrationRequestSent
    case emailConfirmed
    case breachesFound
    case breachesNotFound

    static func < (lhs: DWMOnboardingProgress, rhs: DWMOnboardingProgress) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
