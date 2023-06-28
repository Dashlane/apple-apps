import Foundation

public struct UserCollectionUpload: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case login = "login"
        case alias = "alias"
        case permission = "permission"
        case proposeSignature = "proposeSignature"
        case acceptSignature = "acceptSignature"
        case collectionKey = "collectionKey"
        case proposeSignatureUsingAlias = "proposeSignatureUsingAlias"
    }

        public let login: String

        public let alias: String

    public let permission: Permission

        public let proposeSignature: String

        public let acceptSignature: String?

        public let collectionKey: String?

        public let proposeSignatureUsingAlias: Bool?

    public init(login: String, alias: String, permission: Permission, proposeSignature: String, acceptSignature: String? = nil, collectionKey: String? = nil, proposeSignatureUsingAlias: Bool? = nil) {
        self.login = login
        self.alias = alias
        self.permission = permission
        self.proposeSignature = proposeSignature
        self.acceptSignature = acceptSignature
        self.collectionKey = collectionKey
        self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
    }
}
