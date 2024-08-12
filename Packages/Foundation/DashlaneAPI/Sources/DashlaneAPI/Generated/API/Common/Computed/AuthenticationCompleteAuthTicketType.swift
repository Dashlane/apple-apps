import Foundation

public enum AuthenticationCompleteAuthTicketType: String, Sendable, Equatable, CaseIterable, Codable
{
  case sso = "sso"
  case masterPassword = "master_password"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
