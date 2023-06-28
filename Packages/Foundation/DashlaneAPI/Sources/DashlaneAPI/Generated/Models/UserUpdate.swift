import Foundation

public struct UserUpdate: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case groupKey = "groupKey"
        case permission = "permission"
        case proposeSignature = "proposeSignature"
    }

        public let userId: String

        public let groupKey: String?

    public let permission: Permission?

        public let proposeSignature: String?

    public init(userId: String, groupKey: String? = nil, permission: Permission? = nil, proposeSignature: String? = nil) {
        self.userId = userId
        self.groupKey = groupKey
        self.permission = permission
        self.proposeSignature = proposeSignature
    }
}
