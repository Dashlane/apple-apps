import Foundation

public struct ItemGroupError: Codable, Equatable {

    public let groupId: String

    public let message: String

    public init(groupId: String, message: String) {
        self.groupId = groupId
        self.message = message
    }
}
