import CryptoKit
import Foundation

public struct ECDH {
    
    public typealias PrivateKey = Curve25519.KeyAgreement.PrivateKey
    public typealias PublicKey = Curve25519.KeyAgreement.PublicKey
    
    public let privateKey: PrivateKey
    public let publicKey: PublicKey
    
    public init(privateKey: PrivateKey = PrivateKey()) {
        self.privateKey = privateKey
        self.publicKey = privateKey.publicKey
    }
}
