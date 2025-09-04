import Foundation

public enum Status: String, Sendable, Hashable, Codable, CaseIterable {
  case pending = "pending"
  case accepted = "accepted"
  case refused = "refused"
  case revoked = "revoked"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
