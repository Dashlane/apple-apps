import Foundation
import CoreUserTracking
import CorePremium

public extension UserSpace {
    var logItemSpace: Definition.Space {
        switch self {
        case .both:
            return .all
        case .personal:
            return .personal
        case .business:
            return .professional
        }
    }
}
