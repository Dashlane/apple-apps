import Foundation
import DashlaneCrypto
import CoreSession
import DashTypes

public class SessionCryptoEngineImpl: SessionCryptoEngine {
    enum Error: Swift.Error {
        case invalidCryptoConfig
        case invalidEncryptedPayloadHeader
    }

    var mainCryptoEngine: SpecializedCryptoEngine
    lazy var keyBasedCryptoCenter = CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!
    let logger: Logger

    public var config: CryptoRawConfig {
        let config = mainCryptoEngine.cryptoCenter.config
        let data = config.saltLength > 0 ? mainCryptoEngine.cache?.fixedSalt(ofSize: UInt(config.saltLength)) : nil

        return CryptoRawConfig(fixedSalt: data, parametersHeader: mainCryptoEngine.cryptoCenter.header)
    }

    public var displayedKeyDerivationInfo: String {
        switch mainCryptoEngine.cryptoCenter.config {
        case .argon2dBased:
            return "Argon2d"
        case .pbkdf2Based(let derivation, _):
            let iterationsKCount = Int(derivation.iterations / 1000)
            return "PBKDF2 \(iterationsKCount)K"
        case .kwc3:
            return "PBKDF2 10K"
        case .kwc5, .noDerivation:
            return "No Derivation"
        }
    }

        public init(cryptoCenter: CryptoCenter, secret: EncryptionSecret, cache: MemoryDerivationKeyCache, logger: Logger) {
        self.mainCryptoEngine = SpecializedCryptoEngine(cryptoCenter: cryptoCenter, secret: secret, cache: cache)
        self.logger = logger
    }

    public init(config: CryptoRawConfig, secret: EncryptionSecret, cache: MemoryDerivationKeyCache, logger: Logger) throws {
        self.mainCryptoEngine = try SpecializedCryptoEngine(config: config, secret: secret, cache: cache)
        self.logger = logger
    }

    convenience init(encryptedPayload: Data, secret: EncryptionSecret, cache: MemoryDerivationKeyCache, logger: Logger) throws {
        guard let cryptoCenter = CryptoCenter(from: encryptedPayload) else {
            throw Error.invalidEncryptedPayloadHeader
        }
        self.init(cryptoCenter: cryptoCenter, secret: secret, cache: cache, logger: logger)
    }

        public func update(to config: CryptoRawConfig) throws {
        guard let cryptoCenter = CryptoCenter(from: config.parametersHeader) else {
            throw Error.invalidCryptoConfig
        }

        logErrorForUnexpectedChange(forNewCryptoCenter: cryptoCenter, newRawConfig: config)

        mainCryptoEngine.cryptoCenter = cryptoCenter
        if let fixedSalt = config.fixedSalt {
            mainCryptoEngine.cache?.saveFixedSalt(fixedSalt)
        }
    }

            private func logErrorForUnexpectedChange(forNewCryptoCenter cryptoCenter: CryptoCenter, newRawConfig: CryptoRawConfig) {
        let oldRawConfig = self.config
        guard mainCryptoEngine.cryptoCenter.config.derivationAlgorithm == cryptoCenter.config.derivationAlgorithm else {
            return
        }
        struct SaltUpdateInfo {
            let hasChange: Bool
            let hasFixedBefore: Bool
            let hasFixedAfter: Bool
        }

        let info = SaltUpdateInfo(hasChange: oldRawConfig.fixedSalt == newRawConfig.fixedSalt,
                                  hasFixedBefore: oldRawConfig.fixedSalt != nil,
                                  hasFixedAfter: newRawConfig.fixedSalt != nil)
        logger.fatal("""
                     Updating from same derivation algorithm should not happen \(cryptoCenter.config.derivationAlgorithm)
                     SaltInfo: \(info)
                     Old Header: \(oldRawConfig.parametersHeader)
                     New Header: \(newRawConfig.parametersHeader)
                     """)
    }

    public func decrypt(data: Data) -> Data? {
        mainCryptoEngine.decrypt(data: data)
    }

    public func encrypt(data: Data) -> Data? {
        mainCryptoEngine.encrypt(data: data)
    }
}
