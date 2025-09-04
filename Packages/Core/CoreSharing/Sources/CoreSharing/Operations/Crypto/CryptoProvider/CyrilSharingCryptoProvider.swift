import CoreTypes
import CyrilKit
import Foundation

public struct CyrilSharingCryptoProvider: SharingCryptoProvider {
  let encryptionVariant = RSA.EncryptionVariant.oaep(.sha256)
  let signatureVariant = RSA.SignatureVariant.sha256

  public let cryptoEngineProvider: (SymmetricKey) throws -> CryptoEngine
  public let symmetricKeyProvider: () -> SymmetricKey

  public init(
    cryptoEngineProvider: @escaping (SymmetricKey) throws -> CryptoEngine,
    symmetricKeyProvider: @escaping () -> SymmetricKey
  ) {
    self.cryptoEngineProvider = cryptoEngineProvider
    self.symmetricKeyProvider = symmetricKeyProvider
  }

  public func makeSymmetricKey() -> CyrilKit.SymmetricKey {
    symmetricKeyProvider()
  }

  public func makeAsymmetricKey() throws -> AsymmetricKeyPair {
    try AsymmetricKeyPair(keySize: .rsa2048)
  }

  public func cryptoEngine(using key: SymmetricKey) throws -> CryptoEngine {
    try cryptoEngineProvider(key)
  }

  public func publicKey(fromPemString pemString: String) throws -> PublicKey {
    try PublicKey(pemString: pemString)
  }

  public func privateKey(fromPemString pemString: String) throws -> PrivateKey {
    try PrivateKey(pemString: pemString)
  }

  public func pemString(for key: PublicKey) throws -> String {
    try key.pemString()
  }

  public func pemString(for key: PrivateKey) throws -> String {
    try key.pemString()
  }

  public func decrypter(using privateKey: PrivateKey) -> Decrypter {
    RSA.Decrypter(privateKey: privateKey, variant: encryptionVariant)
  }

  public func encrypter(using publicKey: PublicKey) -> Encrypter {
    RSA.Encrypter(publicKey: publicKey, variant: encryptionVariant)
  }

  public func authenticationCodeProducer(using groupKey: SymmetricKey) -> AuthenticationCodeProducer
  {
    HMAC(key: groupKey, variant: .sha256)
  }

  public func acceptSignatureVerifier(using publicKey: PublicKey) -> SignatureVerifier {
    RSA.SignatureVerifier(publicKey: publicKey, variant: signatureVariant)
  }

  public func acceptMessageSigner(using privateKey: PrivateKey) -> MessageSigner {
    RSA.MessageSigner(privateKey: privateKey, variant: signatureVariant)
  }
}
