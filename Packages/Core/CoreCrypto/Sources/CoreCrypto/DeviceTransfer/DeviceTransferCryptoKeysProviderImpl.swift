import DashTypes
import Foundation
import Sodium

public struct DeviceTransferCryptoKeysProviderImpl: DeviceTransferCryptoKeysProvider {

  public typealias PublicKey = [UInt8]

  public typealias PrivateKey = [UInt8]

  typealias SharedSecretKey = [UInt8]

  typealias Seed = [UInt8]

  typealias SymmeticKey = [UInt8]

  let sodium: Sodium

  let publicKey: PublicKey

  public var publicKeyString: Base64EncodedString {
    return Data(publicKey).base64EncodedString()
  }

  let privateKey: PublicKey

  public let seedD2DMessagePrefix = "DASHLANE_D2D_SAS_SEED"

  public let symmetricKeyD2DMessagePrefix = "DASHLANE_D2D_SYMMETRIC_KEY"

  public init() {
    let sodium = Sodium()
    guard let keyPair = sodium.keyExchange.keyPair() else {
      fatalError("Sodium couldn't create key pair")
    }
    self.init(publicKey: keyPair.publicKey, privateKey: keyPair.secretKey, sodium: sodium)
  }

  public init(publicKey: PublicKey, privateKey: PrivateKey, sodium: Sodium = Sodium()) {
    self.publicKey = publicKey
    self.privateKey = privateKey
    self.sodium = sodium
  }

  public func publicKeyHash() throws -> Base64EncodedString {
    guard let hash = sodium.genericHash.hash(message: publicKey) else {
      throw DeviceTransferError.hashGenerationFailed
    }
    return Data(hash).base64EncodedString()
  }

  public func compare(_ key: Base64EncodedString, hashedKey: Base64EncodedString) throws -> Bool {
    guard let publicKeyHash = try? hashKey(key),
      let publicKeyHashData = Data(base64Encoded: publicKeyHash)?.bytes,
      let otherPublicKeyHash = Data(base64Encoded: hashedKey)?.bytes
    else {
      return false
    }
    return sodium.utils.equals(publicKeyHashData, otherPublicKeyHash)
  }

  public func securityChallengeKeys(
    using publicKey: Base64EncodedString, login: String, transferId: String,
    origin: DeviceTransferOrigin
  ) throws -> SecurityChallengeKeys {
    let sharedSecret =
      origin == .receiver
      ? try clientSharedSecret(with: publicKey) : try serverSharedSecret(with: publicKey)
    let visualSeed = try visualCheckSeed(
      login: login, transferId: transferId, sharedSecret: sharedSecret)
    let message = "\(symmetricKeyD2DMessagePrefix)\(login.count)\(login)\(transferId)"
    let symmetricKey = try symmetricKey(message: message, sharedSecret: sharedSecret)
    let passphrase = try passphrase(for: visualSeed)
    return SecurityChallengeKeys(
      transferId: transferId, symmetricKey: symmetricKey, passphrase: passphrase)
  }

  func serverSharedSecret(with otherPublicKey: Base64EncodedString) throws -> SharedSecretKey {
    guard let otherPublicKey = Data(base64Encoded: otherPublicKey)?.bytes,
      let sessionKeys = sodium.keyExchange.sessionKeyPair(
        publicKey: publicKey, secretKey: privateKey, otherPublicKey: otherPublicKey, side: .SERVER)
    else {
      throw DeviceTransferError.couldNotGenerateServerSharedSecret
    }
    return sessionKeys.tx
  }

  func clientSharedSecret(with otherPublicKey: Base64EncodedString) throws -> SharedSecretKey {
    guard let otherPublicKey = Data(base64Encoded: otherPublicKey)?.bytes,
      let sessionKeys = sodium.keyExchange.sessionKeyPair(
        publicKey: publicKey, secretKey: privateKey, otherPublicKey: otherPublicKey, side: .CLIENT)
    else {
      throw DeviceTransferError.couldNotGenerateClientSharedSecret
    }
    return sessionKeys.rx
  }

  func visualCheckSeed(login: String, transferId: String, sharedSecret: SharedSecretKey) throws
    -> Seed
  {
    let message = "\(seedD2DMessagePrefix)\(login.count)\(login)\(transferId)"
    guard let seed = sodium.genericHash.hash(message: message.bytes, key: sharedSecret) else {
      throw DeviceTransferError.couldNotGenerateSeed
    }
    return seed
  }

  func symmetricKey(message: String, sharedSecret: SharedSecretKey) throws -> SymmeticKey {
    guard let message = message.data(using: .utf8),
      let symmetricKey = sodium.genericHash.hash(
        message: message.bytes, key: sharedSecret, outputLength: 32)
    else {
      throw DeviceTransferError.couldNotGenerateSymmetricKey
    }
    return symmetricKey
  }

  func hashKey(_ key: Base64EncodedString) throws -> Base64EncodedString {
    guard let data = Data(base64Encoded: key) else {
      throw DeviceTransferError.hashGenerationFailed
    }
    guard let hash = sodium.genericHash.hash(message: data.bytes) else {
      throw DeviceTransferError.hashGenerationFailed
    }
    return Data(hash).base64EncodedString()
  }

  func passphrase(for seed: Seed) throws -> [String] {
    return try PassphraseGenerator(seed: Data(seed)).generate().components(separatedBy: " ")
  }

}
