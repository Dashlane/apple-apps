import Foundation

public enum PaymentsAccessibleStoreOffersMode: String, Sendable, Equatable, CaseIterable, Codable {
  case deferred = "DEFERRED"
  case immediateAndChargeProratedPrice = "IMMEDIATE_AND_CHARGE_PRORATED_PRICE"
  case immediateWithoutProration = "IMMEDIATE_WITHOUT_PRORATION"
  case immediateWithTimeProration = "IMMEDIATE_WITH_TIME_PRORATION"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
