import CorePremium
import Foundation

extension UserSpace {
  var identityDashboardSpaceId: String? {
    switch self {
    case .personal:
      return ""
    case .both:
      return nil
    case let .team(space):
      return space.personalDataId
    }
  }

}
