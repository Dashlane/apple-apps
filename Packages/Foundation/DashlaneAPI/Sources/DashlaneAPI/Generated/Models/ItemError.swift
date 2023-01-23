import Foundation

public struct ItemError: Codable, Equatable {

    public let itemId: String

    public let message: String

    public init(itemId: String, message: String) {
        self.itemId = itemId
        self.message = message
    }
}
