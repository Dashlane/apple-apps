import Foundation

public struct UserCollectionDownload: Codable, Equatable {

    public enum RsaStatus: String, Codable, Equatable, CaseIterable {
        case noKey = "noKey"
        case publicKey = "publicKey"
        case sharingKeys = "sharingKeys"
    }

    private enum CodingKeys: String, CodingKey {
        case login = "login"
        case referrer = "referrer"
        case permission = "permission"
        case status = "status"
        case acceptSignature = "acceptSignature"
        case collectionKey = "collectionKey"
        case proposeSignature = "proposeSignature"
        case proposeSignatureUsingAlias = "proposeSignatureUsingAlias"
        case rsaStatus = "rsaStatus"
    }

    public let login: String

    public let referrer: String

    public let permission: Permission

    public let status: Status

    public let acceptSignature: String?

    public let collectionKey: String?

    public let proposeSignature: String?

    public let proposeSignatureUsingAlias: Bool?

    public let rsaStatus: RsaStatus?

    public init(login: String, referrer: String, permission: Permission, status: Status, acceptSignature: String? = nil, collectionKey: String? = nil, proposeSignature: String? = nil, proposeSignatureUsingAlias: Bool? = nil, rsaStatus: RsaStatus? = nil) {
        self.login = login
        self.referrer = referrer
        self.permission = permission
        self.status = status
        self.acceptSignature = acceptSignature
        self.collectionKey = collectionKey
        self.proposeSignature = proposeSignature
        self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
        self.rsaStatus = rsaStatus
    }
}
