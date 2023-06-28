import Foundation

public struct ItemGroupDownload: Codable, Equatable {

    public enum `Type`: String, Codable, Equatable, CaseIterable {
        case items = "items"
        case userGroupKeys = "userGroupKeys"
    }

    private enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case revision = "revision"
        case type = "type"
        case collections = "collections"
        case groups = "groups"
        case items = "items"
        case teamId = "teamId"
        case users = "users"
    }

    public let groupId: String

    public let revision: Int

    public let type: `Type`

    public let collections: [Collections]?

    public let groups: [Groups]?

    public let items: [Items]?

    public let teamId: Int?

    public let users: [UserDownload]?

    public struct Collections: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case uuid = "uuid"
            case name = "name"
            case permission = "permission"
            case status = "status"
            case acceptSignature = "acceptSignature"
            case itemGroupKey = "itemGroupKey"
            case proposeSignature = "proposeSignature"
            case referrer = "referrer"
        }

        public let uuid: String

        public let name: String

        public let permission: Permission

        public let status: Status

        public let acceptSignature: String?

        public let itemGroupKey: String?

        public let proposeSignature: String?

        public let referrer: String?

        public init(uuid: String, name: String, permission: Permission, status: Status, acceptSignature: String? = nil, itemGroupKey: String? = nil, proposeSignature: String? = nil, referrer: String? = nil) {
            self.uuid = uuid
            self.name = name
            self.permission = permission
            self.status = status
            self.acceptSignature = acceptSignature
            self.itemGroupKey = itemGroupKey
            self.proposeSignature = proposeSignature
            self.referrer = referrer
        }
    }

    public struct Groups: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case groupId = "groupId"
            case name = "name"
            case permission = "permission"
            case status = "status"
            case acceptSignature = "acceptSignature"
            case groupKey = "groupKey"
            case proposeSignature = "proposeSignature"
            case referrer = "referrer"
        }

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

        private enum CodingKeys: String, CodingKey {
            case itemId = "itemId"
            case itemKey = "itemKey"
        }

        public let itemId: String

        public let itemKey: String

        public init(itemId: String, itemKey: String) {
            self.itemId = itemId
            self.itemKey = itemKey
        }
    }

    public init(groupId: String, revision: Int, type: `Type`, collections: [Collections]? = nil, groups: [Groups]? = nil, items: [Items]? = nil, teamId: Int? = nil, users: [UserDownload]? = nil) {
        self.groupId = groupId
        self.revision = revision
        self.type = type
        self.collections = collections
        self.groups = groups
        self.items = items
        self.teamId = teamId
        self.users = users
    }
}
