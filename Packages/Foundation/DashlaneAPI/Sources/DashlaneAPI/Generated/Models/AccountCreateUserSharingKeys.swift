import Foundation

public struct AccountCreateUserSharingKeys: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case privateKey = "privateKey"
        case publicKey = "publicKey"
    }

    public let privateKey: String

    public let publicKey: String

    public init(privateKey: String, publicKey: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
