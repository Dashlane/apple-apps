import Foundation

public struct UserGroupDownload: Codable, Equatable {

    public enum `Type`: String, Codable, Equatable, CaseIterable {
        case users = "users"
        case teamAdmins = "teamAdmins"
    }

    private enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case name = "name"
        case type = "type"
        case publicKey = "publicKey"
        case privateKey = "privateKey"
        case revision = "revision"
        case users = "users"
        case externalId = "externalId"
        case familyId = "familyId"
        case teamId = "teamId"
    }

    public let groupId: String

    public let name: String

    public let type: `Type`

    public let publicKey: String

    public let privateKey: String

    public let revision: Int

    public let users: [UserDownload]

    public let externalId: String?

    public let familyId: Int?

    public let teamId: Int?

    public init(groupId: String, name: String, type: `Type`, publicKey: String, privateKey: String, revision: Int, users: [UserDownload], externalId: String? = nil, familyId: Int? = nil, teamId: Int? = nil) {
        self.groupId = groupId
        self.name = name
        self.type = type
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.revision = revision
        self.users = users
        self.externalId = externalId
        self.familyId = familyId
        self.teamId = teamId
    }
}
