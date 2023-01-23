import Foundation

public protocol DerivationKeyCacheDelegate {
    func value(forConfig config: CryptoConfig, password: String, salt: Data) -> Data?
    func set(value: Data, forConfig config: CryptoConfig, password: String, salt: Data)
    func fixedSalt(ofSize size: UInt) -> Data?
    func saveFixedSalt(_ data: Data)
}

public class MemoryDerivationKeyCache: DerivationKeyCacheDelegate {

    private var keysCache = [MemoryCacheKey: Data]()
    private var saltsCache = [UInt: Data]()
    private var readWriteLock = ReadWriteLock()

    public init() {}

    public func value(forConfig config: CryptoConfig, password: String, salt: Data) -> Data? {
        let cacheKey = MemoryCacheKey(config: config, password: password, salt: salt)

        return readWriteLock.withReadLock {
            return keysCache[cacheKey]
        }
    }

    public func set(value: Data, forConfig config: CryptoConfig, password: String, salt: Data) {
        let cacheKey = MemoryCacheKey(config: config, password: password, salt: salt)
        
        readWriteLock.withWriteLock {
            keysCache[cacheKey] = value
        }
    }
    
    public func fixedSalt(ofSize size: UInt) -> Data? {
        return readWriteLock.withReadLock {
            return saltsCache[size]
        }
    }
    
    public func saveFixedSalt(_ data: Data) {
        readWriteLock.withWriteLock {
            self.saltsCache[UInt(data.count)] = data
        }
    }

    private func generaterandomSalt(ofSize size: UInt) -> Data {
        var randomData = [UInt8]()
        for _ in 0..<size {
            randomData.append(UInt8.random(in: UInt8.min..<UInt8.max))
        }
        return Data(randomData)
    }
}

private struct MemoryCacheKey: Equatable, Hashable {
    let config: CryptoConfig
            let passwordHash: Int
    let salt: Data

    init(config: CryptoConfig, password: String, salt: Data) {
        self.config = config
        self.passwordHash = password.hashValue
        self.salt = salt
    }
}
