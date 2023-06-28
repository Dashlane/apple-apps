import Foundation

public struct CollectionDownload: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case name = "name"
        case revision = "revision"
        case publicKey = "publicKey"
        case privateKey = "privateKey"
        case userGroups = "userGroups"
        case users = "users"
    }

    public let uuid: String

    public let name: String

    public let revision: Int

    public let publicKey: String

    public let privateKey: String

    public let userGroups: [UserGroupCollectionDownload]?

    public let users: [UserCollectionDownload]?

    public init(uuid: String, name: String, revision: Int, publicKey: String, privateKey: String, userGroups: [UserGroupCollectionDownload]? = nil, users: [UserCollectionDownload]? = nil) {
        self.uuid = uuid
        self.name = name
        self.revision = revision
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.userGroups = userGroups
        self.users = users
    }
}
