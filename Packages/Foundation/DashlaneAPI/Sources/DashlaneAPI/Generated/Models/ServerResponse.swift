import Foundation

public struct ServerResponse: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case collections = "collections"
        case itemErrors = "itemErrors"
        case itemGroupErrors = "itemGroupErrors"
        case itemGroups = "itemGroups"
        case items = "items"
        case sharingVersion = "sharingVersion"
        case userGroupErrors = "userGroupErrors"
        case userGroups = "userGroups"
    }

    public let collections: [CollectionDownload]?

    public let itemErrors: [ItemError]?

    public let itemGroupErrors: [ItemGroupError]?

    public let itemGroups: [ItemGroupDownload]?

    public let items: [ItemContent]?

    public let sharingVersion: Int?

    public let userGroupErrors: [UserGroupError]?

    public let userGroups: [UserGroupDownload]?

    public init(collections: [CollectionDownload]? = nil, itemErrors: [ItemError]? = nil, itemGroupErrors: [ItemGroupError]? = nil, itemGroups: [ItemGroupDownload]? = nil, items: [ItemContent]? = nil, sharingVersion: Int? = nil, userGroupErrors: [UserGroupError]? = nil, userGroups: [UserGroupDownload]? = nil) {
        self.collections = collections
        self.itemErrors = itemErrors
        self.itemGroupErrors = itemGroupErrors
        self.itemGroups = itemGroups
        self.items = items
        self.sharingVersion = sharingVersion
        self.userGroupErrors = userGroupErrors
        self.userGroups = userGroups
    }
}
