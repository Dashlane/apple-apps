import Foundation

public enum CapabilityStatus: Equatable {
  case available(beta: Bool = false)
  case needsUpgrade
  case unavailable

  public var isAvailable: Bool {
    switch self {
    case .available:
      return true
    case .needsUpgrade, .unavailable:
      return false
    }
  }
}
