import Foundation

public enum AccountType: String, Sendable, Hashable, Codable, CaseIterable {
  case masterPassword = "masterPassword"
  case invisibleMasterPassword = "invisibleMasterPassword"
  case securityKey = "securityKey"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
