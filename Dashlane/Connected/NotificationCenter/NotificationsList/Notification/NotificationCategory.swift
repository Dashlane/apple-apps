import Foundation

public enum NotificationCategory: String, Identifiable, CaseIterable {
  public var id: String {
    rawValue
  }

  case securityAlerts

  case sharing

  case gettingStarted

  case yourAccount

  case whatIsNew

  public static func < (lhs: NotificationCategory, rhs: NotificationCategory) -> Bool {
    return lhs.priority < rhs.priority
  }

  private var priority: Int {
    switch self {
    case .securityAlerts: return 0
    case .sharing: return 1
    case .gettingStarted: return 2
    case .yourAccount: return 3
    case .whatIsNew: return 4
    }
  }
}
