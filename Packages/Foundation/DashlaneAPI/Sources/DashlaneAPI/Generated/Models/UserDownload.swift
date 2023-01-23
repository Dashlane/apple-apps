import Foundation

public struct UserDownload: Codable, Equatable {

    public enum RsaStatus: String, Codable, Equatable, CaseIterable {
        case noKey = "noKey"
        case publicKey = "publicKey"
        case sharingKeys = "sharingKeys"
    }

    public let userId: String

    public let alias: String

    public let referrer: String

    public let permission: Permission

    public let acceptSignature: String?

    public let groupKey: String?

    public let proposeSignature: String?

    public let proposeSignatureUsingAlias: Bool?

    public let rsaStatus: RsaStatus?

    public let status: Status?

    public init(userId: String, alias: String, referrer: String, permission: Permission, acceptSignature: String? = nil, groupKey: String? = nil, proposeSignature: String? = nil, proposeSignatureUsingAlias: Bool? = nil, rsaStatus: RsaStatus? = nil, status: Status? = nil) {
        self.userId = userId
        self.alias = alias
        self.referrer = referrer
        self.permission = permission
        self.acceptSignature = acceptSignature
        self.groupKey = groupKey
        self.proposeSignature = proposeSignature
        self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
        self.rsaStatus = rsaStatus
        self.status = status
    }
}
