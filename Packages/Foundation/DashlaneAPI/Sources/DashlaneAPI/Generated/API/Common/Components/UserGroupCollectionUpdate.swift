import Foundation

public struct UserGroupCollectionUpdate: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case groupUUID = "groupUUID"
    case permission = "permission"
  }

  public let groupUUID: String
  public let permission: Permission

  public init(groupUUID: String, permission: Permission) {
    self.groupUUID = groupUUID
    self.permission = permission
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(groupUUID, forKey: .groupUUID)
    try container.encode(permission, forKey: .permission)
  }
}
