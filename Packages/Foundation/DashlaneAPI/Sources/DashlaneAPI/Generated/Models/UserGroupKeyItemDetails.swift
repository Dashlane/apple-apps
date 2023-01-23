import Foundation

public struct UserGroupKeyItemDetails: Codable, Equatable {

        public let itemId: String

        public let itemGroupRevision: Int

    public init(itemId: String, itemGroupRevision: Int) {
        self.itemId = itemId
        self.itemGroupRevision = itemGroupRevision
    }
}
