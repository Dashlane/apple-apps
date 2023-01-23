import Foundation
import DashTypes

public protocol SecureStoreCryptoProvider {
    func encrypt(_ data: Data, key: Data) throws -> Data
    func decrypt(_ data: Data, key: Data) throws -> Data
    func encrypt(_ data: Data, password: String) throws -> Data
    func decrypt(_ data: Data, password: String) throws -> Data
}

protocol PersistenceProvider {
    func write(_ data: Data?, forKey key: String) throws
    func read(forKey key: String) throws -> Data?
}

public protocol PersistenceStoresProvider {
                    func storeURLForData(identifiedBy identifier: String) throws -> URL
}

public protocol SecureStoreKey {
    var keyString: String { get }
}

public extension RawRepresentable where Self: SecureStoreKey, RawValue == String {
    var keyString: String { return rawValue }
}

public enum SecureStoreError: Error {
    case invalidCipherText
    case encryptionError
    case decryptionError
}

public class SecureStore<Key: SecureStoreKey> {
    public enum Secret {
        case key(Data)
        case password(String)
    }

    internal let secret: EncryptionSecret
    private var cryptoProvider: SecureStoreCryptoProvider
    private var persistenceProvider: PersistenceProvider

    init(secret: EncryptionSecret, cryptoProvider: SecureStoreCryptoProvider, persistenceProvider: PersistenceProvider) {
        self.cryptoProvider = cryptoProvider
        self.persistenceProvider = persistenceProvider
        self.secret = secret
    }

    public func store(_ data: Data?, for key: Key) throws {
        guard let data = data else {
            try persistenceProvider.write(nil, forKey: key.keyString)
            return
        }

        let cipherText = try encrypt(data)
        try persistenceProvider.write(cipherText, forKey: key.keyString)
    }

    public func isDataStored(for key: Key) throws -> Bool {
        guard let cipherText = try persistenceProvider.read(forKey: key.keyString) else {
            return false
        }
        return cipherText.count > 0
    }

    public func retrieveData(for key: Key) throws -> Data? {
        guard let cipherText = try persistenceProvider.read(forKey: key.keyString) else {
            return nil
        }

        guard let clearText = try? decrypt(cipherText) else { return nil }
        return clearText
    }

    private func encrypt(_ data: Data) throws -> Data {
        switch secret {
        case .key(let key):
            return try cryptoProvider.encrypt(data, key: key)
        case .password(let password):
            return try cryptoProvider.encrypt(data, password: password)
        }
    }

    private func decrypt(_ data: Data) throws -> Data {
        switch secret {
        case .key(let key):
            return try cryptoProvider.decrypt(data, key: key)
        case .password(let password):
            return try cryptoProvider.decrypt(data, password: password)
        }
    }

}

extension SecureStore {
    public func store(_ object: String, for key: Key) throws {
        let data = object.data(using: .utf8)
        try store(data, for: key)
    }

    public func retrieveString(for key: Key) throws -> String? {
        guard let data = try retrieveData(for: key) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}

extension SecureStore {
    public func store<T: Encodable>(_ object: T?, for key: Key) throws {
        let data = try PropertyListEncoder().encode(object)
        try store(data, for: key)
    }

    func retrieve<T: Decodable>(_ type: T.Type, for key: Key) throws -> T? {
        guard let data = try retrieveData(for: key) else {
            return nil
        }
        let object = try PropertyListDecoder().decode(type, from: data)
        return object
    }
}
