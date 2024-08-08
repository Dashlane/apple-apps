import Combine
import CoreSettings
import Foundation

import struct DashTypes.Login

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
