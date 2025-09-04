import Foundation

public struct ItemUpload: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case itemId = "itemId"
    case itemKey = "itemKey"
    case content = "content"
    case itemType = "itemType"
  }

  public enum ItemType: String, Sendable, Hashable, Codable, CaseIterable {
    case authentifiant = "AUTHENTIFIANT"
    case securenote = "SECURENOTE"
    case secret = "SECRET"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public let itemId: String
  public let itemKey: String
  public let content: String
  public let itemType: ItemType?

  public init(itemId: String, itemKey: String, content: String, itemType: ItemType? = nil) {
    self.itemId = itemId
    self.itemKey = itemKey
    self.content = content
    self.itemType = itemType
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(itemId, forKey: .itemId)
    try container.encode(itemKey, forKey: .itemKey)
    try container.encode(content, forKey: .content)
    try container.encodeIfPresent(itemType, forKey: .itemType)
  }
}
