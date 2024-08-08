import Foundation

public enum PremiumStatusPlanFeature: String, Sendable, Equatable, CaseIterable, Codable {
  case legacy = "legacy"
  case entryLevel = "entry_level"
  case starter = "starter"
  case team = "team"
  case business = "business"
  case entreprise = "entreprise"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
