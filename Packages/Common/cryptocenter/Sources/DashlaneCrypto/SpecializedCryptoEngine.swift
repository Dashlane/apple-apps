import Foundation
import DashTypes

public struct SpecializedCryptoEngine: CryptoEngine {
    public enum Error: Swift.Error {
        case invalidCryptoConfig
    }
    public var cryptoCenter: CryptoCenter {
        didSet {
            cryptoCenter.derivationKeyCacheDelegate = cache
        }
    }
    public let secret: EncryptionSecret
    public let cache: MemoryDerivationKeyCache?

    public init(config: CryptoRawConfig,
                secret: EncryptionSecret,
                cache: MemoryDerivationKeyCache) throws {
        guard let cryptoCenter = CryptoCenter(from: config.parametersHeader) else {
            throw Error.invalidCryptoConfig
        }
        self.init(cryptoCenter: cryptoCenter, secret: secret, cache: cache)
        if let fixedSalt = config.fixedSalt {
            cache.saveFixedSalt(fixedSalt)
        }
    }

    public init(cryptoCenter: CryptoCenter,
                secret: EncryptionSecret,
                cache: MemoryDerivationKeyCache? = nil) {
        self.cryptoCenter = cryptoCenter
        self.secret = secret
        self.cache = cache
        self.cryptoCenter.derivationKeyCacheDelegate = cache
    }

    public func encrypt(data: Data) -> Data? {
        return try? cryptoCenter.encrypt(data: data, with: secret)
    }

    public func decrypt(data: Data) -> Data? {
        guard var decryptionCryptoCenter = CryptoCenter(from: data) else {
            return nil
        }
        decryptionCryptoCenter.derivationKeyCacheDelegate = cryptoCenter.derivationKeyCacheDelegate
        return try? decryptionCryptoCenter.decrypt(data: data, with: secret)
    }
}
