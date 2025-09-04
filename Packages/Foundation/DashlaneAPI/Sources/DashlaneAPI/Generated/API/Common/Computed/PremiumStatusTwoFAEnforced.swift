import Foundation

public enum PremiumStatusTwoFAEnforced: String, Sendable, Hashable, Codable, CaseIterable {
  case disabled = "disabled"
  case newDevice = "newDevice"
  case login = "login"
  case none = ""
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
