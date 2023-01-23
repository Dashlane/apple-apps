import Foundation

public struct ItemContent: Codable, Equatable {

    public let itemId: String

    public let content: String

    public let timestamp: Int

    public init(itemId: String, content: String, timestamp: Int) {
        self.itemId = itemId
        self.content = content
        self.timestamp = timestamp
    }
}
