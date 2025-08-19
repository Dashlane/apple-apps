import Foundation

public struct UserGroupCollectionInvite: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case groupUUID = "groupUUID"
    case permission = "permission"
    case collectionKey = "collectionKey"
    case proposeSignature = "proposeSignature"
    case acceptSignature = "acceptSignature"
  }

  public let groupUUID: String
  public let permission: Permission
  public let collectionKey: String
  public let proposeSignature: String
  public let acceptSignature: String?

  public init(
    groupUUID: String, permission: Permission, collectionKey: String, proposeSignature: String,
    acceptSignature: String? = nil
  ) {
    self.groupUUID = groupUUID
    self.permission = permission
    self.collectionKey = collectionKey
    self.proposeSignature = proposeSignature
    self.acceptSignature = acceptSignature
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(groupUUID, forKey: .groupUUID)
    try container.encode(permission, forKey: .permission)
    try container.encode(collectionKey, forKey: .collectionKey)
    try container.encode(proposeSignature, forKey: .proposeSignature)
    try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
  }
}
