import Foundation

public enum PremiumStatusPlanFeature: String, Sendable, Hashable, Codable, CaseIterable {
  case legacy = "legacy"
  case standard = "standard"
  case starter = "starter"
  case team = "team"
  case business = "business"
  case entreprise = "entreprise"
  case businessplus = "businessplus"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
