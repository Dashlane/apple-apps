import Foundation

public struct AuthenticationCompleteAuthTicketRemoteKeys: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case uuid = "uuid"
    case key = "key"
    case type = "type"
  }

  public let uuid: String
  public let key: String
  public let type: AuthenticationCompleteAuthTicketType

  public init(uuid: String, key: String, type: AuthenticationCompleteAuthTicketType) {
    self.uuid = uuid
    self.key = key
    self.type = type
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(key, forKey: .key)
    try container.encode(type, forKey: .type)
  }
}
