import Foundation

public struct UserGroupCollectionUpdate: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case groupUUID = "groupUUID"
        case permission = "permission"
    }

        public let groupUUID: String

    public let permission: Permission

    public init(groupUUID: String, permission: Permission) {
        self.groupUUID = groupUUID
        self.permission = permission
    }
}
