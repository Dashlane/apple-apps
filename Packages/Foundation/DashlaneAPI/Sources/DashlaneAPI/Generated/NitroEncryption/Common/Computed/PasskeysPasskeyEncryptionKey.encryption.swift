import Foundation

public struct PasskeysPasskeyEncryptionKey: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case uuid = "uuid"
    case key = "key"
  }

  public let uuid: String
  public let key: String

  public init(uuid: String, key: String) {
    self.uuid = uuid
    self.key = key
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(key, forKey: .key)
  }
}
