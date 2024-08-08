import CyrilKit
import DashTypes
import Foundation

protocol EncryptionProvider: Sendable {
  func makeEncrypter() throws -> (header: Data, encrypter: Encrypter & FileHandleEncrypter)
  func makeDecrypter(forEncryptedData data: Data) throws -> (
    encryptedDataPosition: Int, decrypter: Decrypter & FileHandleDecrypter
  )
}

extension CryptoConfiguration {
  func makeEncryptionProvider(secret: EncryptionSecret, fixedSalt: Data?) throws
    -> any EncryptionProvider
  {
    switch self {
    case .flexible(let flexibleCryptoConfiguration):
      return try FlexibleConfigurationEncryptionProvider(
        configuration: flexibleCryptoConfiguration,
        fixedSalt: fixedSalt,
        secret: secret)
    case .legacy(let legacyCryptoConfiguration):
      return try legacyCryptoConfiguration.makeEncryptionProvider(
        secret: secret, fixedSalt: fixedSalt)
    }
  }
}

extension LegacyCryptoConfiguration {
  func makeEncryptionProvider(secret: EncryptionSecret, fixedSalt: Data?) throws
    -> any EncryptionProvider
  {
    switch (self, secret) {
    case (.kwc3, .password(let password)):
      return try LegacyKWC3EncryptionProvider(password: password, fixedSalt: fixedSalt)
    case (.kwc5, .key(let key)):
      return try LegacyKWC5EncryptionProvider(key: key)
    default:
      throw CryptoEngineError.unsupportedConfiguration(
        configuration: .legacy(self), key: secret.isPassword ? .derived : .direct)
    }
  }
}
