import Foundation

public enum MplessTransferAlgorithm: String, Sendable, Equatable, CaseIterable, Codable {
  case directHKDFSHA256 = "direct+HKDF-SHA-256"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
