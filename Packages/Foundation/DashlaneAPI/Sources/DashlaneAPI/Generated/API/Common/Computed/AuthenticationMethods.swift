import Foundation

public enum AuthenticationMethods: String, Sendable, Equatable, CaseIterable, Codable {
  case emailToken = "email_token"
  case totp = "totp"
  case duoPush = "duo_push"
  case dashlaneAuthenticator = "dashlane_authenticator"
  case u2f = "u2f"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
