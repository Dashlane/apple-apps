import Foundation

public enum DataLeakMonitoringServiceError: Error, Codable, Equatable {

  case ok
  case invalidEmail
  case emailAlreadyActive
  case optinAlreadyInProgress
  case numberOfAcceptedMonitoredEmailsExceeded
  case noActiveSubscriptionForThisEmail
  case contentDidNotChange
  case unknownError(Error?)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self = DataLeakMonitoringServiceError(rawValue: try container.decode(String.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.stringValue)
  }

  public init(rawValue: String) {
    switch rawValue {
    case "OK": self = .ok
    case "EMAIL_IS_INVALID": self = .invalidEmail
    case "USER_HAS_ALREADY_AN_ACTIVE_SUBSCRIPTION": self = .emailAlreadyActive
    case "USER_HAS_ALREADY_A_PENDING_SUBSCRIPTION": self = .optinAlreadyInProgress
    case "USER_HAS_TOO_MANY_SUBSCRIPTIONS": self = .numberOfAcceptedMonitoredEmailsExceeded
    case "USER_HAS_NO_SUBSCRIPTION": self = .noActiveSubscriptionForThisEmail
    default:
      self = .unknownError(nil)
    }
  }

  public var stringValue: String {
    switch self {
    case .ok: return "OK"
    case .invalidEmail: return "EMAIL_IS_INVALID"
    case .emailAlreadyActive: return "USER_HAS_ALREADY_AN_ACTIVE_SUBSCRIPTION"
    case .optinAlreadyInProgress: return "USER_HAS_ALREADY_A_PENDING_SUBSCRIPTION"
    case .numberOfAcceptedMonitoredEmailsExceeded: return "USER_HAS_TOO_MANY_SUBSCRIPTIONS"
    case .noActiveSubscriptionForThisEmail: return "USER_HAS_NO_SUBSCRIPTION"
    default: return "UNKNOWN"
    }
  }

  public static func == (lhs: DataLeakMonitoringServiceError, rhs: DataLeakMonitoringServiceError)
    -> Bool
  {
    return lhs.stringValue == rhs.stringValue
  }
}
