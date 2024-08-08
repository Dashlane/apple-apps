import Foundation

public struct AccountCreateUserConsents: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case consentType = "consentType"
    case status = "status"
  }

  public let consentType: AccountCreateUserConsentType
  public let status: Bool

  public init(consentType: AccountCreateUserConsentType, status: Bool) {
    self.consentType = consentType
    self.status = status
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(consentType, forKey: .consentType)
    try container.encode(status, forKey: .status)
  }
}
