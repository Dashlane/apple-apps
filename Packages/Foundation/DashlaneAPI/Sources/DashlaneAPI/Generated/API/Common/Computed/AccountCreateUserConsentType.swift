import Foundation

public enum AccountCreateUserConsentType: String, Sendable, Equatable, CaseIterable, Codable {
  case privacyPolicyAndToS = "privacyPolicyAndToS"
  case emailsOffersAndTips = "emailsOffersAndTips"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
