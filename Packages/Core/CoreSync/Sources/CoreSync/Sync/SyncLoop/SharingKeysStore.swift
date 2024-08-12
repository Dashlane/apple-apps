import CyrilKit
import DashTypes
import DashlaneAPI
import Foundation

public actor SharingKeysStore {
  let url: URL
  let localCryptoEngine: CryptoEngine
  let privateKeyRemoteCryptoEngine: CryptoEngine
  let logger: Logger

  public var needsKey: Bool {
    return keyPairValue == nil
  }
  private var keyPairValue: AsymmetricKeyPair?

  public init(
    url: URL,
    localCryptoEngine: CryptoEngine,
    privateKeyRemoteCryptoEngine: CryptoEngine,
    logger: Logger
  ) async {
    self.url = url
    self.localCryptoEngine = localCryptoEngine
    self.privateKeyRemoteCryptoEngine = privateKeyRemoteCryptoEngine
    self.logger = logger
    self.loadFromDisk()
  }

  public func keyPair() -> AsymmetricKeyPair? {
    return keyPairValue
  }

  private func loadFromDisk() {
    do {
      guard FileManager.default.fileExists(atPath: url.path) else {
        return
      }
      let data = try Data(contentsOf: url).decrypt(using: localCryptoEngine)
      let sharingKeys = try JSONDecoder().decode(PersistedSharingKeys.self, from: data)

      keyPairValue = try AsymmetricKeyPair(sharingKeys)
    } catch {
      logger.fatal("cannot load sharing keys from disk", error: error)
    }
  }

  func save(_ sharingKeys: SyncSharingKeys) throws {
    do {
      let keyPair = try AsymmetricKeyPair(
        sharingKeys: sharingKeys, privateKeyCryptoEngine: privateKeyRemoteCryptoEngine)
      self.keyPairValue = keyPair
      try JSONEncoder()
        .encode(keyPair.makePersistedSharingKeys())
        .encrypt(using: localCryptoEngine)
        .write(to: url, options: [.atomic])
    } catch {
      logger.error("cannot save sharing keys on disk", error: error)
      throw error
    }
  }

  func save(_ keyPair: AsymmetricKeyPair) {
    self.keyPairValue = keyPair
  }
}

public enum SharingKeysError: Error {
  public enum ParseReason {
    case invalidBase64
    case invalidUTF8String
    case decryptFailed(Error)
    case rsaError(RSA.RSAError)
  }
  case cannotParseSharingKeys(ParseReason)
  case cannotGenerateSharingKeys
}

extension AsymmetricKeyPair {
  public static func makeAccountDefaultKeyPair() throws -> AsymmetricKeyPair {
    return try AsymmetricKeyPair(keySize: .rsa2048)
  }
}

extension AccountCreateUserSharingKeys {
  public static func makeAccountDefault(privateKeyCryptoEngine: CryptoEngine) throws
    -> AccountCreateUserSharingKeys
  {
    let sharingKey = try AsymmetricKeyPair(keySize: .rsa2048)
      .makeSharingKeys(privateKeyCryptoEngine: privateKeyCryptoEngine)

    return AccountCreateUserSharingKeys(
      privateKey: sharingKey.privateKey, publicKey: sharingKey.publicKey)
  }
}

private struct PersistedSharingKeys: Codable {
  let publicKey: String
  let privateKey: String
}

extension AsymmetricKeyPair {
  fileprivate init(_ persistedSharingKeys: PersistedSharingKeys) throws {
    let publicKey = try PublicKey(pemString: persistedSharingKeys.publicKey)
    let privateKey = try PrivateKey(pemString: persistedSharingKeys.privateKey)
    self.init(publicKey: publicKey, privateKey: privateKey)
  }

  fileprivate func makePersistedSharingKeys() throws -> PersistedSharingKeys {
    let publickey = try publicKey.pemString()
    let privateKey = try privateKey.pemString()

    return PersistedSharingKeys(publicKey: publickey, privateKey: privateKey)
  }
}

extension AsymmetricKeyPair {
  public init(sharingKeys: SyncSharingKeys, privateKeyCryptoEngine: CryptoEngine) throws {
    do {
      let publicKey = try PublicKey(pemString: sharingKeys.publicKey)

      guard let encryptedPrivateKey = Data(base64Encoded: sharingKeys.privateKey) else {
        throw SharingKeysError.cannotParseSharingKeys(.invalidBase64)
      }

      let decryptedPrivateKey = try encryptedPrivateKey.decrypt(using: privateKeyCryptoEngine)

      let privateKeyPemString =
        if let string = String(data: decryptedPrivateKey, encoding: .utf8) {
          string
        } else if let string = String(data: decryptedPrivateKey, encoding: .utf16) {
          string
        } else {
          throw SharingKeysError.cannotParseSharingKeys(.invalidUTF8String)
        }

      let privateKey = try PrivateKey(pemString: privateKeyPemString)
      self.init(publicKey: publicKey, privateKey: privateKey)
    } catch let error as RSA.RSAError {
      throw SharingKeysError.cannotParseSharingKeys(.rsaError(error))
    }
  }

  public func makeSharingKeys(privateKeyCryptoEngine: CryptoEngine) throws -> SyncSharingKeys {
    let publicKey = try publicKey.pemString()
    let encryptedPrivateKey = try privateKey
      .pemString()
      .data(using: .utf8)?
      .encrypt(using: privateKeyCryptoEngine)
      .base64EncodedString()

    guard let encryptedPrivateKey = encryptedPrivateKey else {
      throw SharingKeysError.cannotGenerateSharingKeys
    }

    return SyncSharingKeys(privateKey: encryptedPrivateKey, publicKey: publicKey)
  }
}
