import DashTypes
import Foundation

public final class KeyedSecureStore<Key: StoreKey>: KeyedStore, Sendable {
  let cryptoEngine: CryptoEngine
  private let persistenceEngine: StorePersistenceEngine

  public init(cryptoEngine: CryptoEngine, persistenceEngine: StorePersistenceEngine) {
    self.cryptoEngine = cryptoEngine
    self.persistenceEngine = persistenceEngine
  }

  public func exists(for key: Key) -> Bool {
    return persistenceEngine.exists(for: key)
  }

  public func store(_ data: Data?, for key: Key) throws {
    guard let data = data else {
      try persistenceEngine.write(nil, for: key)
      return
    }

    let cipherText = try cryptoEngine.encrypt(data)

    try persistenceEngine.write(cipherText, for: key)
  }

  public func retrieveData(for key: Key) throws -> Data {
    guard let cipherText = try? persistenceEngine.read(for: key) else {
      throw KeyedStoreError.noValue(key)
    }

    return try cryptoEngine.decrypt(cipherText)
  }
}

public enum CryptoError: Error {
  case encryptionFailure
  case decryptionFailure
}
