import Foundation

public struct UserDownload: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case userId = "userId"
    case alias = "alias"
    case referrer = "referrer"
    case permission = "permission"
    case acceptSignature = "acceptSignature"
    case groupKey = "groupKey"
    case proposeSignature = "proposeSignature"
    case proposeSignatureUsingAlias = "proposeSignatureUsingAlias"
    case rsaStatus = "rsaStatus"
    case status = "status"
  }

  public enum RsaStatus: String, Sendable, Hashable, Codable, CaseIterable {
    case noKey = "noKey"
    case publicKey = "publicKey"
    case sharingKeys = "sharingKeys"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public let userId: String
  public let alias: String
  public let referrer: String
  public let permission: Permission
  public let acceptSignature: String?
  public let groupKey: String?
  public let proposeSignature: String?
  public let proposeSignatureUsingAlias: Bool?
  public let rsaStatus: RsaStatus?
  public let status: Status?

  public init(
    userId: String, alias: String, referrer: String, permission: Permission,
    acceptSignature: String? = nil, groupKey: String? = nil, proposeSignature: String? = nil,
    proposeSignatureUsingAlias: Bool? = nil, rsaStatus: RsaStatus? = nil, status: Status? = nil
  ) {
    self.userId = userId
    self.alias = alias
    self.referrer = referrer
    self.permission = permission
    self.acceptSignature = acceptSignature
    self.groupKey = groupKey
    self.proposeSignature = proposeSignature
    self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
    self.rsaStatus = rsaStatus
    self.status = status
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userId, forKey: .userId)
    try container.encode(alias, forKey: .alias)
    try container.encode(referrer, forKey: .referrer)
    try container.encode(permission, forKey: .permission)
    try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
    try container.encodeIfPresent(groupKey, forKey: .groupKey)
    try container.encodeIfPresent(proposeSignature, forKey: .proposeSignature)
    try container.encodeIfPresent(proposeSignatureUsingAlias, forKey: .proposeSignatureUsingAlias)
    try container.encodeIfPresent(rsaStatus, forKey: .rsaStatus)
    try container.encodeIfPresent(status, forKey: .status)
  }
}
