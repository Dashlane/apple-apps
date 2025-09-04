import Foundation

public enum Permission: String, Sendable, Hashable, Codable, CaseIterable {
  case admin = "admin"
  case limited = "limited"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
