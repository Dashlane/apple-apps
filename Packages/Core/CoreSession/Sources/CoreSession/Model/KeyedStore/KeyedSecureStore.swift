import Foundation
import DashTypes

public class KeyedSecureStore<Key: StoreKey>: KeyedStore {
    var cryptoEngine: CryptoEngine
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

        guard let cipherText = cryptoEngine.encrypt(data: data) else {
            throw CryptoError.encryptionFailure
        }

        try persistenceEngine.write(cipherText, for: key)
    }

    public func retrieveData(for key: Key) throws -> Data {
        guard let cipherText = try? persistenceEngine.read(for: key) else {
            throw KeyedStoreError.noValue(key)
        }

        guard let clearText = cryptoEngine.decrypt(data: cipherText) else {
            throw KeyedStoreError.wrongDecypher(key)
        }
        return clearText
    }
}

public enum CryptoError: Error {
    case encryptionFailure
    case decryptionFailure
}
