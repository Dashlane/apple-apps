import Foundation

public struct UserGroupKeyItemDetails: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case itemId = "itemId"
        case itemGroupRevision = "itemGroupRevision"
    }

        public let itemId: String

        public let itemGroupRevision: Int

    public init(itemId: String, itemGroupRevision: Int) {
        self.itemId = itemId
        self.itemGroupRevision = itemGroupRevision
    }
}
