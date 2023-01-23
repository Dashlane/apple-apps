import Foundation

public struct ServerResponse: Codable, Equatable {

    public let itemErrors: [ItemError]?

    public let itemGroupErrors: [ItemGroupError]?

    public let itemGroups: [ItemGroupDownload]?

    public let items: [ItemContent]?

    public let sharingVersion: Int?

    public let userGroupErrors: [UserGroupError]?

    public let userGroups: [UserGroupDownload]?

    public init(itemErrors: [ItemError]? = nil, itemGroupErrors: [ItemGroupError]? = nil, itemGroups: [ItemGroupDownload]? = nil, items: [ItemContent]? = nil, sharingVersion: Int? = nil, userGroupErrors: [UserGroupError]? = nil, userGroups: [UserGroupDownload]? = nil) {
        self.itemErrors = itemErrors
        self.itemGroupErrors = itemGroupErrors
        self.itemGroups = itemGroups
        self.items = items
        self.sharingVersion = sharingVersion
        self.userGroupErrors = userGroupErrors
        self.userGroups = userGroups
    }
}
