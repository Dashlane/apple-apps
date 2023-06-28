import Foundation
import CoreSession
import DashTypes
import DashlaneCrypto

public struct SessionCryptoEngineProvider: CoreSession.CryptoEngineProvider {
    let cache: MemoryDerivationKeyCache
    let logger: Logger

    public init(logger: Logger) {
        cache = MemoryDerivationKeyCache()
        self.logger = logger
    }

    public func makeLocalKey() -> Data {
        Random.randomData(ofSize: 64)
    }

    public func sessionCryptoEngine(for setting: CryptoRawConfig, masterKey: MasterKey) throws -> SessionCryptoEngine {
        return try SessionCryptoEngineImpl(config: setting, secret: masterKey.secret, cache: cache, logger: logger)
    }

    public func sessionCryptoEngine(forEncryptedPayload payload: Data, masterKey: MasterKey) throws -> SessionCryptoEngine {
        return try SessionCryptoEngineImpl(encryptedPayload: payload, secret: masterKey.secret, cache: cache, logger: logger)
    }

    public func defaultCryptoRawConfig(for masterKey: MasterKey) -> CryptoRawConfig {
        switch masterKey {
        case .masterPassword:
            return CryptoRawConfig.masterPasswordBasedDefault
        case .ssoKey:
            return CryptoRawConfig.keyBasedDefault
        }
    }

    public func cryptoEngine(for key: Data) throws -> CryptoEngine {
        let config: CryptoRawConfig = key.count == 64 ? CryptoRawConfig.keyBasedDefault : CryptoRawConfig.legacyKeyBasedDefault
        let cryptoCenter = CryptoCenter(from: config.parametersHeader)!
        return SpecializedCryptoEngine(cryptoCenter: cryptoCenter, secret: .key(key))
    }

}
