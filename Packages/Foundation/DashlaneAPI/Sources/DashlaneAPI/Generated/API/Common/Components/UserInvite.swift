import Foundation

public struct UserInvite: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case userId = "userId"
    case alias = "alias"
    case permission = "permission"
    case proposeSignature = "proposeSignature"
    case groupKey = "groupKey"
    case proposeSignatureUsingAlias = "proposeSignatureUsingAlias"
  }

  public let userId: String
  public let alias: String
  public let permission: Permission
  public let proposeSignature: String
  public let groupKey: String?
  public let proposeSignatureUsingAlias: Bool?

  public init(
    userId: String, alias: String, permission: Permission, proposeSignature: String,
    groupKey: String? = nil, proposeSignatureUsingAlias: Bool? = nil
  ) {
    self.userId = userId
    self.alias = alias
    self.permission = permission
    self.proposeSignature = proposeSignature
    self.groupKey = groupKey
    self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userId, forKey: .userId)
    try container.encode(alias, forKey: .alias)
    try container.encode(permission, forKey: .permission)
    try container.encode(proposeSignature, forKey: .proposeSignature)
    try container.encodeIfPresent(groupKey, forKey: .groupKey)
    try container.encodeIfPresent(proposeSignatureUsingAlias, forKey: .proposeSignatureUsingAlias)
  }
}
