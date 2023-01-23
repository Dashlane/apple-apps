import Foundation

public struct UserGroupUpdate: Codable, Equatable {

        public let groupId: String

    public let permission: Permission

    public init(groupId: String, permission: Permission) {
        self.groupId = groupId
        self.permission = permission
    }
}
