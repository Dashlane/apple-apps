import Foundation

public enum PaymentsAccessibleStoreOffersReason2: String, Sendable, Hashable, Codable, CaseIterable
{
  case notForB2C = "not_for_b2c"
  case notInThisTier = "not_in_this_tier"
  case notReleased = "not_released"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
