import Foundation

public enum TeamsSsoStatus: String, Sendable, Equatable, CaseIterable, Codable {
  case activated = "activated"
  case pendingActivation = "pending_activation"
  case pendingDeactivation = "pending_deactivation"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
