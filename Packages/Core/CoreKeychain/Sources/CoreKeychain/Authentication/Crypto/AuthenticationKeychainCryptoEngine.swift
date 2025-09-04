import CoreTypes
import CryptoKit
import CyrilKit
import Foundation
import LogFoundation

public protocol AuthenticationKeychainCryptoEngineProvider {
  func keychainCryptoEngine(using key: CyrilKit.SymmetricKey) throws -> CryptoEngine
  func keychainCryptoEngine(forEncryptedPayload: Data, using secret: EncryptionSecret) throws
    -> CryptoEngine
}

public struct AuthenticationKeychainCryptoEngineProviderMock:
  AuthenticationKeychainCryptoEngineProvider
{
  let mode: MockCryptoEngine.OperationMode

  public func keychainCryptoEngine(using key: CyrilKit.SymmetricKey) throws -> CryptoEngine {
    return .mock(mode)
  }
  public func keychainCryptoEngine(forEncryptedPayload: Data, using secret: EncryptionSecret) throws
    -> CryptoEngine
  {
    return .mock(mode)
  }
}

extension AuthenticationKeychainCryptoEngineProvider
where Self == AuthenticationKeychainCryptoEngineProviderMock {
  public static func mock(mode: MockCryptoEngine.OperationMode = .reverseEncrypt)
    -> AuthenticationKeychainCryptoEngineProviderMock
  {
    .init(mode: mode)
  }
}

public struct AuthenticationKeychainCryptoEngine {
  let cryptoEngineProvider: AuthenticationKeychainCryptoEngineProvider

  public init(cryptoEngineProvider: AuthenticationKeychainCryptoEngineProvider) {
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  public func encrypt(_ data: Data, accessMode: KeychainAccessMode, accessGroup: String) throws
    -> Data
  {
    switch accessMode {
    case .afterBiometricAuthentication:
      return try encrypt(data, using: .dashlaneKey)
    case .whenDeviceUnlocked:
      switch SecureEnclave.cryptoKeys(accessGroup: accessGroup) {
      case .available(let keys):
        return try encrypt(data, using: .secureEnclaveKeys(keys))
      case .unavailable:
        return try encrypt(data, using: .dashlaneKey)
      }
    }
  }

  public func decrypt(_ data: Data, accessGroup: String) throws -> Data {
    switch SecureEnclave.cryptoKeys(accessGroup: accessGroup) {
    case .available(let keys):
      do {
        return try decrypt(data, using: .secureEnclaveKeys(keys))
      } catch {
        return try decrypt(data, using: .dashlaneKey)
      }
    case .unavailable:
      return try decrypt(data, using: .dashlaneKey)
    }
  }
}

extension AuthenticationKeychainCryptoEngine {
  private enum CryptoKey {
    case secureEnclaveKeys(SecureEnclaveKeys)
    case dashlaneKey
  }

  public enum DecryptKeyStrategy: CaseIterable {
    case expandedKey
    case key
    case password
  }

  @Loggable
  public struct DecryptError: Error {
    public let errors: [DecryptKeyStrategy: Error]
  }

  private func encrypt(_ data: Data, using cryptoKey: CryptoKey) throws -> Data {
    switch cryptoKey {
    case .secureEnclaveKeys(let keys):
      guard
        let data = SecKeyCreateEncryptedData(
          keys.publicKey, .eciesEncryptionStandardX963SHA256AESGCM, data as CFData, nil) as? Data
      else {
        throw SecureEnclaveError.encryptFailed
      }

      return data
    case .dashlaneKey:
      let key = ApplicationSecrets.Keychain.makeSymmetricKey(expanded: true)
      return try cryptoEngineProvider.keychainCryptoEngine(using: key)
        .encrypt(data)
    }
  }

  private func decrypt(_ data: Data, using cryptoKey: CryptoKey) throws -> Data {
    switch cryptoKey {
    case .secureEnclaveKeys(let keys):
      guard
        let data = SecKeyCreateDecryptedData(
          keys.privateKey, .eciesEncryptionStandardX963SHA256AESGCM, data as CFData, nil) as? Data
      else {
        throw SecureEnclaveError.decryptFailed
      }
      return data

    case .dashlaneKey:
      var errors: [DecryptKeyStrategy: Error] = [:]

      for strategy in DecryptKeyStrategy.allCases {
        let secret = ApplicationSecrets.Keychain.makeSecret(strategy: strategy)
        do {
          return try cryptoEngineProvider.keychainCryptoEngine(
            forEncryptedPayload: data, using: secret
          )
          .decrypt(data)
        } catch {
          errors[strategy] = error
          continue
        }
      }

      throw DecryptError(errors: errors)
    }
  }
}

extension ApplicationSecrets.Keychain {
  static func makeSymmetricKey(expanded: Bool) -> CyrilKit.SymmetricKey {
    guard let data = key.data(using: .utf8) else {
      fatalError()
    }

    if expanded && data.count < 64 {
      return Data(SHA512.hash(data: data))
    } else {
      return data
    }
  }

  static func makeSecret(strategy: AuthenticationKeychainCryptoEngine.DecryptKeyStrategy)
    -> EncryptionSecret
  {
    switch strategy {
    case .expandedKey:
      .key(ApplicationSecrets.Keychain.makeSymmetricKey(expanded: true))
    case .key:
      .key(ApplicationSecrets.Keychain.makeSymmetricKey(expanded: false))
    case .password:
      .password(key)
    }
  }
}
