import Foundation

public struct ItemError: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case itemId = "itemId"
        case message = "message"
    }

    public let itemId: String

    public let message: String

    public init(itemId: String, message: String) {
        self.itemId = itemId
        self.message = message
    }
}
