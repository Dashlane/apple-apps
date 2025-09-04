import Foundation

public struct UserGroupCollectionDownload: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case uuid = "uuid"
    case name = "name"
    case permission = "permission"
    case status = "status"
    case acceptSignature = "acceptSignature"
    case collectionKey = "collectionKey"
    case proposeSignature = "proposeSignature"
    case referrer = "referrer"
  }

  public let uuid: String
  public let name: String
  public let permission: Permission
  public let status: Status
  public let acceptSignature: String?
  public let collectionKey: String?
  public let proposeSignature: String?
  public let referrer: String?

  public init(
    uuid: String, name: String, permission: Permission, status: Status,
    acceptSignature: String? = nil, collectionKey: String? = nil, proposeSignature: String? = nil,
    referrer: String? = nil
  ) {
    self.uuid = uuid
    self.name = name
    self.permission = permission
    self.status = status
    self.acceptSignature = acceptSignature
    self.collectionKey = collectionKey
    self.proposeSignature = proposeSignature
    self.referrer = referrer
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(name, forKey: .name)
    try container.encode(permission, forKey: .permission)
    try container.encode(status, forKey: .status)
    try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
    try container.encodeIfPresent(collectionKey, forKey: .collectionKey)
    try container.encodeIfPresent(proposeSignature, forKey: .proposeSignature)
    try container.encodeIfPresent(referrer, forKey: .referrer)
  }
}
