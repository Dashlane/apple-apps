import Foundation

public struct SyncUploadDataRemoteKeys: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case uuid = "uuid"
    case key = "key"
    case type = "type"
  }

  public let uuid: String
  public let key: String
  public let type: SyncUploadDataType

  public init(uuid: String, key: String, type: SyncUploadDataType) {
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
