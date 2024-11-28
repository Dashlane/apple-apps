import Foundation

public enum VaultItemsLimit: Equatable {
  case unlimited
  case reachingLimit(count: Int, limit: Int)
  case limited(count: Int, limit: Int, enforceFreeze: Bool)

  var isLimited: Bool {
    switch self {
    case .limited:
      return true
    default:
      return false
    }
  }
}
