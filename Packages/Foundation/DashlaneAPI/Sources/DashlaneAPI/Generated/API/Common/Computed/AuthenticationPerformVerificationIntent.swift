import Foundation

public enum AuthenticationPerformVerificationIntent: String, Sendable, Hashable, Codable,
  CaseIterable
{
  case defaultIntent = "default_intent"
  case accountDeleteOrReset = "account_delete_or_reset"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
