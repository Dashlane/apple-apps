import Foundation

public struct AccountCreateUserSharingKeys: Codable, Equatable {

    public let privateKey: String

    public let publicKey: String

    public init(privateKey: String, publicKey: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
