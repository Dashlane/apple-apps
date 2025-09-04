import Foundation

public enum PaymentsAccessibleStoreOffersReason: String, Sendable, Hashable, Codable, CaseIterable {
  case notForB2C = "not_for_b2c"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
