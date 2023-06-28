import Foundation

public struct ItemContent: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
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
}
