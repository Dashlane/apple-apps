import Foundation

public enum PasskeysPasskeyType: String, Sendable, Hashable, Codable, CaseIterable {
  case publicKey = "public-key"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
