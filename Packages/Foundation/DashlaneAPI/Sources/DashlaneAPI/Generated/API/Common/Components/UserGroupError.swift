import Foundation

public struct UserGroupError: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case groupId = "groupId"
    case message = "message"
  }

  public let groupId: String
  public let message: String

  public init(groupId: String, message: String) {
    self.groupId = groupId
    self.message = message
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(groupId, forKey: .groupId)
    try container.encode(message, forKey: .message)
  }
}
