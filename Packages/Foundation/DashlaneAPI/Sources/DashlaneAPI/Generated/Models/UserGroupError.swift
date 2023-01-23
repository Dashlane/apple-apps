import Foundation

public struct UserGroupError: Codable, Equatable {

    public let groupId: String?

    public let message: String?

    public init(groupId: String? = nil, message: String? = nil) {
        self.groupId = groupId
        self.message = message
    }
}
