import Foundation

public struct ItemError: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case itemId = "itemId"
    case message = "message"
  }

  public let itemId: String
  public let message: String

  public init(itemId: String, message: String) {
    self.itemId = itemId
    self.message = message
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(itemId, forKey: .itemId)
    try container.encode(message, forKey: .message)
  }
}
