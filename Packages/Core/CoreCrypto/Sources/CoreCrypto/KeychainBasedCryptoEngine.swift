import CoreTypes
import Foundation
import SwiftTreats

public struct KeychainBasedCryptoEngine: CoreTypes.CryptoEngine {

  private func generateCommunicationKey() -> Data {
    Data.random(ofSize: 64)
  }

  @KeychainItemAccessor
  private var keychainKey: Data?

  private let allowKeyRegenerationIfFailure: Bool

  var encryptionKey: Data {
    guard let key = keychainKey, key.count == 64 else {
      let generated = generateCommunicationKey()
      keychainKey = generated
      return generated
    }
    return key
  }

  public init(
    encryptionKeyId: String,
    accessGroup: String,
    allowKeyRegenerationIfFailure: Bool,
    shouldAccessAfterFirstUnlock: Bool
  ) {
    self._keychainKey = .init(
      identifier: encryptionKeyId, accessGroup: accessGroup,
      shouldAccessAfterFirstUnlock: shouldAccessAfterFirstUnlock)
    self.allowKeyRegenerationIfFailure = allowKeyRegenerationIfFailure
  }

  private var cryptoEngine: CryptoEngine {
    get throws {
      try CryptoConfiguration.defaultNoDerivation.makeCryptoEngine(secret: .key(encryptionKey))
    }
  }

  public func encrypt(_ data: Data) throws -> Data {
    try cryptoEngine.encrypt(data)
  }

  public func decrypt(_ data: Data) throws -> Data {
    do {
      return try cryptoEngine.decrypt(data)
    } catch {
      if allowKeyRegenerationIfFailure {
        keychainKey = nil
      }

      throw error
    }
  }
}
