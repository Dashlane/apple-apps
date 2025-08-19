import Foundation

public enum MplessTransferEllipticCurve: String, Sendable, Hashable, Codable, CaseIterable {
  case x25519 = "X25519"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
