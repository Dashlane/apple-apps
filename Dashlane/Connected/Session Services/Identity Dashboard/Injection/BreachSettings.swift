import Foundation
import Combine
import CoreSettings
import struct DashTypes.Login
import DashlaneAppKit

enum BreachSettingsKey: String, CaseIterable, LocalSettingsKey {
    case lastRevisionForPublicBreaches = "securityDashboardLastKnownBreachesRevisionKey"
    case lastUpdateDataForDataLeaks = "securityDashboardLastDataLeakUpdateDate"

    var type: Any.Type {
        switch self {
        case .lastRevisionForPublicBreaches:
            return Int.self
        case .lastUpdateDataForDataLeaks:
            return TimeInterval.self
        }
    }
}
