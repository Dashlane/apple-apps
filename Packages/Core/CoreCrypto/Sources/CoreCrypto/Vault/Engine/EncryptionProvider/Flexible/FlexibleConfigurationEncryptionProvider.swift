import CyrilKit
import DashTypes
import Foundation

struct FlexibleConfigurationEncryptionProvider: EncryptionProvider {
  enum Key {
    case key(SymmetricKey)
    case derived(KeyDerivation)
  }

  let marker: Data
  let key: Key
  let encryption: EncryptionConfiguration

  init(configuration: FlexibleCryptoConfiguration, fixedSalt: Data?, secret: EncryptionSecret)
    throws
  {
    encryption = configuration.encryption
    marker = try configuration.marker()

    switch (configuration.derivation, secret) {
    case let (.some(derivation), .password(password)):
      key = .derived(
        try KeyDerivation(
          password: password,
          fixedSalt: fixedSalt,
          algorithm: derivation,
          derivedKeyLength: encryption.cipherMode.defaultKeySize)
      )

    case (nil, let .key(aKey)):
      guard encryption.cipherMode.supportedKeySizes.contains(aKey.count) else {
        throw CryptoEngineError.invalidKeySize(
          size: aKey.count, expected: encryption.cipherMode.supportedKeySizes)
      }
      key = .key(aKey)

    default:
      throw CryptoEngineError.unsupportedConfiguration(
        configuration: .flexible(configuration),
        key: secret.isPassword ? .derived : .direct)
    }
  }

  func makeEncrypter() throws -> (header: Data, encrypter: FileHandleEncrypter & Encrypter) {
    let key: SymmetricKey
    let prefixHeader: Data

    switch self.key {
    case let .key(aKey):
      key = aKey
      prefixHeader = marker
    case let .derived(derivation):
      let salt = derivation.makeSalt()
      prefixHeader = marker + salt

      key = try derivation.key(usingSalt: salt)
    }

    let iv = Data.makeIV(size: encryption.ivLength)
    let header = prefixHeader + iv
    let keys = try encryption.cipherMode.keys(from: key)
    let encrypter = try AESCBCHMAC(
      key: keys.encryptedDataKey,
      hmacKey: keys.hmacKey,
      initializationVector: iv)

    return (header, encrypter)
  }

  func makeDecrypter(forEncryptedData data: Data) throws -> (
    encryptedDataPosition: Int, decrypter: FileHandleDecrypter & Decrypter
  ) {
    var offset = marker.count
    let key: SymmetricKey

    switch self.key {
    case let .key(aKey):
      key = aKey

    case let .derived(derivation):
      let salt = try data[safe: offset..<offset + derivation.saltLength]
      offset += derivation.saltLength
      key = try derivation.key(usingSalt: salt)
    }

    let iv = try data[safe: offset..<offset + encryption.ivLength]
    let encryptedDataPosition = iv.endIndex
    let keys = try encryption.cipherMode.keys(from: key)
    let encrypter = try AESCBCHMAC(
      key: keys.encryptedDataKey,
      hmacKey: keys.hmacKey,
      initializationVector: iv)

    return (encryptedDataPosition, encrypter)
  }
}
