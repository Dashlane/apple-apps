import Foundation

public struct UserGroupError: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case message = "message"
    }

    public let groupId: String

    public let message: String

    public init(groupId: String, message: String) {
        self.groupId = groupId
        self.message = message
    }
}
