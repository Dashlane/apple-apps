import Foundation

public struct CollectionUpdate: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case collectionUUID = "collectionUUID"
    case permission = "permission"
  }

  public let collectionUUID: String
  public let permission: Permission

  public init(collectionUUID: String, permission: Permission) {
    self.collectionUUID = collectionUUID
    self.permission = permission
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(collectionUUID, forKey: .collectionUUID)
    try container.encode(permission, forKey: .permission)
  }
}
