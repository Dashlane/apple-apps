import Foundation

public struct AuditLogDetails: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case type = "type"
    case captureLog = "captureLog"
    case domain = "domain"
    case encryptedDetails = "encryptedDetails"
  }

  public enum `Type`: String, Sendable, Hashable, Codable, CaseIterable {
    case authentifiant = "AUTHENTIFIANT"
    case securenote = "SECURENOTE"
    case secret = "SECRET"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public let type: `Type`
  public let captureLog: Bool?
  public let domain: String?
  public let encryptedDetails: String?

  public init(
    type: `Type`, captureLog: Bool? = nil, domain: String? = nil, encryptedDetails: String? = nil
  ) {
    self.type = type
    self.captureLog = captureLog
    self.domain = domain
    self.encryptedDetails = encryptedDetails
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    try container.encodeIfPresent(captureLog, forKey: .captureLog)
    try container.encodeIfPresent(domain, forKey: .domain)
    try container.encodeIfPresent(encryptedDetails, forKey: .encryptedDetails)
  }
}
