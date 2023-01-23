import Foundation

public struct SyncSharingKeys: Codable, Equatable {

    public let privateKey: String

    public let publicKey: String

    public init(privateKey: String, publicKey: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
