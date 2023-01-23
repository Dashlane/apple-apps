import Foundation

public struct ItemGroupDownload: Codable, Equatable {

    public enum `Type`: String, Codable, Equatable, CaseIterable {
        case items = "items"
        case userGroupKeys = "userGroupKeys"
    }

    public let groupId: String

    public let revision: Int

    public let type: `Type`

    public let autoAccept: Bool?

    public let groups: [Groups]?

    public let items: [Items]?

    public let teamId: Int?

    public let users: [UserDownload]?

    public struct Groups: Codable, Equatable {

        public let groupId: String

        public let name: String

        public let permission: Permission

        public let status: Status

        public let acceptSignature: String?

        public let groupKey: String?

        public let proposeSignature: String?

        public let referrer: String?

        public init(groupId: String, name: String, permission: Permission, status: Status, acceptSignature: String? = nil, groupKey: String? = nil, proposeSignature: String? = nil, referrer: String? = nil) {
            self.groupId = groupId
            self.name = name
            self.permission = permission
            self.status = status
            self.acceptSignature = acceptSignature
            self.groupKey = groupKey
            self.proposeSignature = proposeSignature
            self.referrer = referrer
        }
    }

    public struct Items: Codable, Equatable {

        public let itemId: String

        public let itemKey: String

        public init(itemId: String, itemKey: String) {
            self.itemId = itemId
            self.itemKey = itemKey
        }
    }

    public init(groupId: String, revision: Int, type: `Type`, autoAccept: Bool? = nil, groups: [Groups]? = nil, items: [Items]? = nil, teamId: Int? = nil, users: [UserDownload]? = nil) {
        self.groupId = groupId
        self.revision = revision
        self.type = type
        self.autoAccept = autoAccept
        self.groups = groups
        self.items = items
        self.teamId = teamId
        self.users = users
    }
}
