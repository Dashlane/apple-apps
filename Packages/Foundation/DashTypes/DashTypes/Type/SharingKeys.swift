import Foundation

public struct SharingKeys: Codable {
    enum CodingKeys: String, CodingKey {
        case encryptedPrivateKey = "privateKey"
        case publicKey
    }

        public let publicKey: String
        public let encryptedPrivateKey: String

    public init(publicKey: String, encryptedPrivateKey: String) {
        self.publicKey = publicKey
        self.encryptedPrivateKey = encryptedPrivateKey
    }
}
