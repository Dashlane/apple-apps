import Foundation

public struct UserUpload: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case userId = "userId"
    case alias = "alias"
    case permission = "permission"
    case proposeSignature = "proposeSignature"
    case acceptSignature = "acceptSignature"
    case groupKey = "groupKey"
    case proposeSignatureUsingAlias = "proposeSignatureUsingAlias"
  }

  public let userId: String
  public let alias: String
  public let permission: Permission
  public let proposeSignature: String
  public let acceptSignature: String?
  public let groupKey: String?
  public let proposeSignatureUsingAlias: Bool?

  public init(
    userId: String, alias: String, permission: Permission, proposeSignature: String,
    acceptSignature: String? = nil, groupKey: String? = nil, proposeSignatureUsingAlias: Bool? = nil
  ) {
    self.userId = userId
    self.alias = alias
    self.permission = permission
    self.proposeSignature = proposeSignature
    self.acceptSignature = acceptSignature
    self.groupKey = groupKey
    self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userId, forKey: .userId)
    try container.encode(alias, forKey: .alias)
    try container.encode(permission, forKey: .permission)
    try container.encode(proposeSignature, forKey: .proposeSignature)
    try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
    try container.encodeIfPresent(groupKey, forKey: .groupKey)
    try container.encodeIfPresent(proposeSignatureUsingAlias, forKey: .proposeSignatureUsingAlias)
  }
}
