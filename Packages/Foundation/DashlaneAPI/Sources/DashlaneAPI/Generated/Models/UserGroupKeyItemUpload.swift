import Foundation

public struct UserGroupKeyItemUpload: Codable, Equatable {

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
