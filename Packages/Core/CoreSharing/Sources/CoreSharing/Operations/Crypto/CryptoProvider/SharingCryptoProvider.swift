import CyrilKit
import DashTypes
import Foundation

public protocol SharingCryptoProvider {
  func makeSymmetricKey() -> SymmetricKey

  func makeAsymmetricKey() throws -> AsymmetricKeyPair

  func cryptoEngine(using key: SymmetricKey) throws -> CryptoEngine

  func publicKey(fromPemString pemString: String) throws -> PublicKey

  func privateKey(fromPemString pemString: String) throws -> PrivateKey

  func pemString(for pemString: PublicKey) throws -> String

  func pemString(for pemString: PrivateKey) throws -> String

  func decrypter(using privateKey: PrivateKey) -> Decrypter

  func encrypter(using publicKey: PublicKey) -> Encrypter

  func authenticationCodeProducer(using key: SymmetricKey) -> AuthenticationCodeProducer

  func acceptSignatureVerifier(using publicKey: PublicKey) -> SignatureVerifier

  func acceptMessageSigner(using privateKey: PrivateKey) -> MessageSigner
}
