import Foundation
import DashTypes
import CyrilKit


public protocol SharingCryptoProvider {
        func makeSymmetricKey() -> SymmetricKey

                func cryptoEngine(using key: SymmetricKey) -> CryptoEngine
    
        func publicKey(fromPemString pemString: String) throws -> PublicKey
    
        func privateKey(fromPemString pemString: String) throws -> PrivateKey
    
                func decrypter(using privateKey: PrivateKey) -> Decrypter
    
                func encrypter(using publicKey: PublicKey) -> Encrypter
    
        func proposeSignatureProducer(using groupKey: SymmetricKey) -> AuthenticationCodeProducer
    
        func acceptSignatureVerifier(using publicKey: PublicKey) -> SignatureVerifier
    
        func acceptMessageSigner(using privateKey: PrivateKey) -> MessageSigner
}

extension SharingCryptoProvider {
    func encrypt(_ key: SymmetricKey, withPublicPemString publicPemString: String) throws -> String {
        let publicKey = try publicKey(fromPemString: publicPemString)
        let cryptoEngine = encrypter(using: publicKey)
        return try cryptoEngine.encrypt(key).base64EncodedString()
    }
}
