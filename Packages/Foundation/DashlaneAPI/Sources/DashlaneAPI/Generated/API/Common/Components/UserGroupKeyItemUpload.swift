import Foundation

public struct UserGroupKeyItemUpload: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case itemId = "itemId"
    case itemKey = "itemKey"
    case content = "content"
    case itemGroupRevision = "itemGroupRevision"
  }

  public let itemId: String
  public let itemKey: String
  public let content: String
  public let itemGroupRevision: Int

  public init(itemId: String, itemKey: String, content: String, itemGroupRevision: Int) {
    self.itemId = itemId
    self.itemKey = itemKey
    self.content = content
    self.itemGroupRevision = itemGroupRevision
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(itemId, forKey: .itemId)
    try container.encode(itemKey, forKey: .itemKey)
    try container.encode(content, forKey: .content)
    try container.encode(itemGroupRevision, forKey: .itemGroupRevision)
  }
}
