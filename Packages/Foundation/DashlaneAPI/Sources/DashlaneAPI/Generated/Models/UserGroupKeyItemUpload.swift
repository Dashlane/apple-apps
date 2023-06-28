import Foundation

public struct UserGroupKeyItemUpload: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
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
}
