import Foundation

public enum ProvisioningMethod: String, Sendable, Equatable, CaseIterable, Codable {
  case user = "USER"
  case tac = "TAC"
  case ad = "AD"
  case scim = "SCIM"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
