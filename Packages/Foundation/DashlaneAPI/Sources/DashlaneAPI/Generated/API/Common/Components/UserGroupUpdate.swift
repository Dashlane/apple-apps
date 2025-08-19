import Foundation

public struct UserGroupUpdate: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case groupId = "groupId"
    case permission = "permission"
  }

  public let groupId: String
  public let permission: Permission

  public init(groupId: String, permission: Permission) {
    self.groupId = groupId
    self.permission = permission
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(groupId, forKey: .groupId)
    try container.encode(permission, forKey: .permission)
  }
}
