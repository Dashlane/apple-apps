import Foundation

public struct ItemContent: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case itemId = "itemId"
    case content = "content"
    case timestamp = "timestamp"
  }

  public let itemId: String
  public let content: String
  public let timestamp: Int

  public init(itemId: String, content: String, timestamp: Int) {
    self.itemId = itemId
    self.content = content
    self.timestamp = timestamp
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(itemId, forKey: .itemId)
    try container.encode(content, forKey: .content)
    try container.encode(timestamp, forKey: .timestamp)
  }
}
