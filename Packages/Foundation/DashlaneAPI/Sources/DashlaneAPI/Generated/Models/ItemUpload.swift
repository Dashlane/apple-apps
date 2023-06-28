import Foundation

public struct ItemUpload: Codable, Equatable {

        public enum ItemType: String, Codable, Equatable, CaseIterable {
        case authentifiant = "AUTHENTIFIANT"
        case securenote = "SECURENOTE"
    }

    private enum CodingKeys: String, CodingKey {
        case itemId = "itemId"
        case itemKey = "itemKey"
        case content = "content"
        case itemType = "itemType"
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
}
