import Foundation

public enum PaymentsAccessibleStoreOffersNudgeTypes: String, Sendable, Hashable, Codable,
  CaseIterable
{
  case compromised = "compromised"
  case weak = "weak"
  case reused = "reused"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
