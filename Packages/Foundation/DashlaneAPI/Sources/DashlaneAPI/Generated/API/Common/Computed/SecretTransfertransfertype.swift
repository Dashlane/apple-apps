import Foundation

public enum SecretTransfertransfertype: String, Sendable, Equatable, CaseIterable, Codable {
  case universal = "universal"
  case proximity = "proximity"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
