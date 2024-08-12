import Foundation

public enum AuthenticationMethodsAccountType: String, Sendable, Equatable, CaseIterable, Codable {
  case masterPassword = "masterPassword"
  case invisibleMasterPassword = "invisibleMasterPassword"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
