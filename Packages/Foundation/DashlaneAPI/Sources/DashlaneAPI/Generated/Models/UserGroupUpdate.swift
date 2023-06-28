import Foundation

public struct UserGroupUpdate: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case permission = "permission"
    }

        public let groupId: String

    public let permission: Permission

    public init(groupId: String, permission: Permission) {
        self.groupId = groupId
        self.permission = permission
    }
}
