import Foundation

public enum PaymentsAccessibleStoreOffersDuration: String, Sendable, Equatable, CaseIterable,
  Codable
{
  case yearly = "yearly"
  case monthly = "monthly"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
