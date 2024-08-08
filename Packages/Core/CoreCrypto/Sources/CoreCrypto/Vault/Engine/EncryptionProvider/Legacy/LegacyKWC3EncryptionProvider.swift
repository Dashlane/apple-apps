import CyrilKit
import Foundation

import enum CryptoKit.Insecure

struct LegacyKWC3EncryptionProvider: EncryptionProvider {
  static let marker = LegacyCryptoConfiguration.kwc3.rawValue.data(using: .utf8)!

  static func encodePassword(_ password: String) -> Data {
    return Data(password.utf16.map { UInt8($0 & 0x00FF) })
  }

  let derivation: KeyDerivation

  init(password: String, fixedSalt: Data?) throws {
    derivation = try KeyDerivation(
      password: Self.encodePassword(password),
      fixedSalt: fixedSalt,
      algorithm: .pbkdf2(.kwc3),
      derivedKeyLength: 32)
  }

  init(derivation: KeyDerivation) throws {
    self.derivation = derivation
  }

  func makeEncrypter() throws -> (header: Data, encrypter: Encrypter & FileHandleEncrypter) {
    let salt = derivation.makeSalt()
    let key = try derivation.key(usingSalt: salt)

    let iv = Self.makeIV(key: key, salt: salt)

    let header = salt + Self.marker
    let encrypter = try AESCBC(key: key, initializationVector: iv)

    return (header, encrypter)
  }

  func makeDecrypter(forEncryptedData data: Data) throws -> (
    encryptedDataPosition: Int, decrypter: Decrypter & FileHandleDecrypter
  ) {
    let salt = try data[safe: ..<32]
    let key = try derivation.key(usingSalt: salt)

    let iv = Self.makeIV(key: key, salt: salt)

    let encryptedDataPosition = salt.endIndex + Self.marker.count
    let decrypter = try AESCBC(key: key, initializationVector: iv)

    return (encryptedDataPosition, decrypter)
  }
}

extension LegacyKWC3EncryptionProvider {
  static func makeFallbackProvider(password: String, fixedSalt: Data?) throws
    -> LegacyKWC3EncryptionProvider
  {
    try LegacyKWC3EncryptionProvider(
      derivation: .init(
        password:
          password,
        fixedSalt: fixedSalt,
        algorithm: .pbkdf2(.kwc3),
        derivedKeyLength: 32))
  }
}

extension PBKDF2Configuration {
  static var `default`: PBKDF2Configuration { kwc3 }

  static let kwc3 = PBKDF2Configuration(
    saltLength: 32,
    iterations: 10204,
    hashAlgorithm: .sha1)
}

extension LegacyKWC3EncryptionProvider {
  static func makeIV(key: SymmetricKey, salt: Data) -> Data {
    let data = key + salt[0..<8]
    var buffer = [data.sha1()]

    for index in 1..<4 {
      let nextHash = (buffer[index - 1] + data).sha1()
      buffer.append(nextHash)
    }

    return Data(buffer.joined())[32..<48]
  }
}

extension Data {
  fileprivate func sha1() -> Data {
    let digest = Insecure.SHA1.hash(data: self)
    return Data(digest)
  }
}
