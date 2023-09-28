import Foundation

public struct UserCollectionUpdate: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case login = "login"
        case collectionKey = "collectionKey"
        case permission = "permission"
        case proposeSignature = "proposeSignature"
    }

        public let login: String

        public let collectionKey: String?

    public let permission: Permission?

        public let proposeSignature: String?

    public init(login: String, collectionKey: String? = nil, permission: Permission? = nil, proposeSignature: String? = nil) {
        self.login = login
        self.collectionKey = collectionKey
        self.permission = permission
        self.proposeSignature = proposeSignature
    }
}
