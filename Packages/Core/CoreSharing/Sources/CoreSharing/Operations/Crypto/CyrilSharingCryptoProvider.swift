import Foundation
import CyrilKit
import DashTypes

public struct CyrilSharingCryptoProvider: SharingCryptoProvider {
    let encryptionVariant = RSA.EncryptionVariant.oaep(.sha256)
    let signatureVariant = RSA.SignatureVariant.sha256

    public init(cryptoEngineProvider: @escaping (SymmetricKey) -> CryptoEngine, symmetricKeyProvider: @escaping () -> SymmetricKey) {
        self.cryptoEngineProvider = cryptoEngineProvider
        self.symmetricKeyProvider = symmetricKeyProvider
    }

    public func makeSymmetricKey() -> CyrilKit.SymmetricKey {
        symmetricKeyProvider()
    }

        public let cryptoEngineProvider: (SymmetricKey) -> CryptoEngine
    public let symmetricKeyProvider: () -> SymmetricKey

    public func cryptoEngine(using key: SymmetricKey) -> CryptoEngine {
        cryptoEngineProvider(key)
    }

    public func publicKey(fromPemString pemString: String) throws -> PublicKey {
        try PublicKey(rsaPemString: pemString)
    }

    public func privateKey(fromPemString pemString: String) throws -> PrivateKey {
        try PrivateKey(rsaPemString: pemString)
    }

    public func decrypter(using privateKey: PrivateKey) -> Decrypter {
        RSA.Decrypter(privateKey: privateKey, variant: encryptionVariant)
    }

    public func encrypter(using publicKey: PublicKey) -> Encrypter {
        RSA.Encrypter(publicKey: publicKey, variant: encryptionVariant)
    }

    public func proposeSignatureProducer(using groupKey: SymmetricKey) -> ProposeSignatureProducer {
        HMAC(key: groupKey, variant: .sha256)
    }

    public func acceptSignatureVerifier(using publicKey: PublicKey) -> SignatureVerifier {
        RSA.SignatureVerifier(publicKey: publicKey, variant: signatureVariant)
    }

    public func acceptMessageSigner(using privateKey: PrivateKey) -> MessageSigner {
        RSA.MessageSigner(privateKey: privateKey, variant: signatureVariant)
    }
}

public typealias ProposeSignatureProducer = AuthenticationCodeProducer
