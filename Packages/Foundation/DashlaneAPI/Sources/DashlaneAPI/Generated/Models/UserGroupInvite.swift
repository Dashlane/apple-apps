import Foundation

public struct UserGroupInvite: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case permission = "permission"
        case groupKey = "groupKey"
        case proposeSignature = "proposeSignature"
        case acceptSignature = "acceptSignature"
    }

        public let groupId: String

    public let permission: Permission

        public let groupKey: String

        public let proposeSignature: String

        public let acceptSignature: String?

    public init(groupId: String, permission: Permission, groupKey: String, proposeSignature: String, acceptSignature: String? = nil) {
        self.groupId = groupId
        self.permission = permission
        self.groupKey = groupKey
        self.proposeSignature = proposeSignature
        self.acceptSignature = acceptSignature
    }
}
