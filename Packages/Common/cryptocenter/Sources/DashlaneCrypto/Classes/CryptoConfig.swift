import Foundation

public struct BaseConfig: Hashable {
        public let version: Int
        public let derivationAlgorithm: DerivationAlgorithm
        public let encryptionAlgorithm: EncryptionAlgorithm
        public let cipherMode: AESMode
        public let ivLength: Int
}

public struct PBKDF2Configuration: Hashable {
        public let saltLength: Int
        public let iterations: Int
        public let pseudoRandomAlgorithm: PseudoRandomAlgorithm
}

public struct Argon2Configuration: Hashable {
        public let iterations: Int
        public let memoryCost: Int
        public let parallelism: Int
        public let saltLength: Int
}

public enum CryptoConfig {
    case kwc3
    case kwc5
    case argon2dBased(derivationAlgorithm: Argon2Configuration, baseConfig: BaseConfig)
    case pbkdf2Based(derivationAlgorithm: PBKDF2Configuration, baseConfig: BaseConfig)
    case noDerivation(baseConfig: BaseConfig)

    public var cipherMode: AESMode {
        switch self {
        case .argon2dBased(_, let baseConfig),
             .pbkdf2Based(_, let baseConfig),
             .noDerivation(let baseConfig):
            return baseConfig.cipherMode
        case .kwc3, .kwc5:
            return .cbc
        }
    }

    public var saltLength: Int {
        switch self {
        case .kwc3:
            return DefaultValues.KWC3.saltLength
        case .argon2dBased(let argon2config, _):
            return argon2config.saltLength
        case .pbkdf2Based(let derivationAlgorithm, baseConfig: _):
            return derivationAlgorithm.saltLength
        case .noDerivation, .kwc5:
            return 0
        }
    }

    public var ivLength: Int {
        switch self {
        case .kwc3:
            return DefaultValues.KWC3.ivLength
        case .kwc5:
            return DefaultValues.KWC5.ivLength
        case .argon2dBased(_, let baseConfig),
             .pbkdf2Based(_, let baseConfig):
            return baseConfig.ivLength
        case .noDerivation(let baseConfig):
            return baseConfig.ivLength
        }
    }

    public var encryptionAlgorithm: EncryptionAlgorithm {
        switch self {
        case .kwc3:
            return .aes256
        case .kwc5:
            return .aes256
        case .argon2dBased(_, let baseConfig),
             .noDerivation(let baseConfig),
             .pbkdf2Based(_, let baseConfig):
            return baseConfig.encryptionAlgorithm
        }
    }

    public var derivationAlgorithm: DerivationAlgorithm {
        switch self {
        case .kwc3:
            return .pbkdf2
        case .kwc5:
            return .none
        case .argon2dBased(_, let baseConfig),
             .noDerivation(let baseConfig),
             .pbkdf2Based(_, let baseConfig):
            return baseConfig.derivationAlgorithm
        }
    }
}

extension CryptoConfig: Hashable {
}
