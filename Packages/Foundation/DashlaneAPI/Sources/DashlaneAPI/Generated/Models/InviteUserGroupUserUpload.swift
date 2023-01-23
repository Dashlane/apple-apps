import Foundation

public struct InviteUserGroupUserUpload: Codable, Equatable {

        public let alias: String

    public let permission: Permission

        public let proposeSignature: String

        public let acceptSignature: String?

        public let groupKey: String?

        public let proposeSignatureUsingAlias: Bool?

        public let userId: String?

    public init(alias: String, permission: Permission, proposeSignature: String, acceptSignature: String? = nil, groupKey: String? = nil, proposeSignatureUsingAlias: Bool? = nil, userId: String? = nil) {
        self.alias = alias
        self.permission = permission
        self.proposeSignature = proposeSignature
        self.acceptSignature = acceptSignature
        self.groupKey = groupKey
        self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
        self.userId = userId
    }
}
