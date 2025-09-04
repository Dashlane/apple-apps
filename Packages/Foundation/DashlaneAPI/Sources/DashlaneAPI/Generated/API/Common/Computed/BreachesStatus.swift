import Foundation

public enum BreachesStatus: String, Sendable, Hashable, Codable, CaseIterable {
  case legacy = "legacy"
  case live = "live"
  case staging = "staging"
  case deleted = "deleted"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
