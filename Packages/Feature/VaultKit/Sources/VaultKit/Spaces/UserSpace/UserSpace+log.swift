import CorePremium
import Foundation
import UserTrackingFoundation

extension UserSpace {
  public var logItemSpace: Definition.Space {
    switch self {
    case .both:
      return .all
    case .personal:
      return .personal
    case .team:
      return .professional
    }
  }
}
