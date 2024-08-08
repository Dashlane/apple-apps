@preconcurrency import CryptoKit
import CyrilKit
import DashTypes
import Foundation

struct LegacyKWC5EncryptionProvider: EncryptionProvider {

  static let marker = LegacyCryptoConfiguration.kwc5.rawValue.data(using: .utf8)!

  let hmacKey: HMACKey
  let encryptedDataKey: EncryptedDataKey

  init(key: CyrilKit.SymmetricKey) throws {
    guard EncryptionConfiguration.AESMode.cbchmac.supportedKeySizes.contains(key.count) else {
      throw CryptoEngineError.invalidKeySize(
        size: key.count, expected: EncryptionConfiguration.AESMode.cbchmac.supportedKeySizes)
    }

    (hmacKey, encryptedDataKey) = key.expandKeysUsingHash()
  }

  func makeEncrypter() throws -> (header: Data, encrypter: Encrypter & FileHandleEncrypter) {
    let iv = Data.makeIV(size: 16)
    let header = iv + Data.random(ofSize: 16) + Self.marker
    let encrypter = try AESCBCHMAC(
      key: encryptedDataKey,
      hmacKey: hmacKey,
      initializationVector: iv)

    return (header, encrypter)
  }

  func makeDecrypter(forEncryptedData data: Data) throws -> (
    encryptedDataPosition: Int, decrypter: Decrypter & FileHandleDecrypter
  ) {
    let iv = try data[safe: ..<16]
    let encryptedDataPosition = iv.count + 16 + Self.marker.count
    let decrypter = try AESCBCHMAC(
      key: encryptedDataKey, hmacKey: hmacKey, initializationVector: iv)

    return (encryptedDataPosition, decrypter)
  }
}
