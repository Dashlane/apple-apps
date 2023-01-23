import Foundation

public typealias CryptoEngine = EncryptEngine & DecryptEngine

public protocol EncryptEngine {
    func encrypt(data: Data) -> Data?
}

public protocol DecryptEngine {
    func decrypt(data: Data) -> Data?
}

public enum CryptoEngineError: Swift.Error {
    case encryptFailed
    case decryptFailed
}

extension Data {
    public func decrypt(using cryptoEngine: DecryptEngine) throws -> Data {
        guard let decoded = cryptoEngine.decrypt(data: self) else {
            throw CryptoEngineError.decryptFailed
        }
        return decoded
    }

    public func encrypt(using cryptoEngine: EncryptEngine) throws  -> Data {
        guard let encoded = cryptoEngine.encrypt(data: self) else {
            throw CryptoEngineError.encryptFailed
        }
        return encoded
    }

}

public struct FakeCryptoEngine: CryptoEngine {
    public init() {
        
    }
    
    public func encrypt(data: Data) -> Data? {
        return Data(data.reversed())
    }
    
    public func decrypt(data: Data) -> Data? {
        return Data(data.reversed())
    }
}

public enum EncryptionSecret: Equatable {
    case key(Data)
    case password(String)
}
