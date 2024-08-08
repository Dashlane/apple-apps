import Foundation

public enum AutofillActivationStatus {
  case unknown
  case enabled
  case disabled

  public var isEnabled: Bool? {
    switch self {
    case .unknown: return nil
    case .enabled: return true
    case .disabled: return false
    }
  }
}
