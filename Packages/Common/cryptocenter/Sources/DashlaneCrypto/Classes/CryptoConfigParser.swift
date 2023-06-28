import Foundation

public struct CryptoConfigParser {

    public static func header(from configuration: CryptoConfig) -> String {
        switch configuration {
            case .kwc3:
                return LegacyMarker.kwc3.rawValue
            case .kwc5:
                return LegacyMarker.kwc5.rawValue
            case let .argon2dBased(derivationAlgorithm, baseConfig):
                return """
            $\(baseConfig.version)\
            $argon2d\
            $\(derivationAlgorithm.saltLength)\
            $\(derivationAlgorithm.iterations)\
            $\(derivationAlgorithm.memoryCost)\
            $\(derivationAlgorithm.parallelism)\
            $\(baseConfig.encryptionAlgorithm.rawValue)\
            $\(baseConfig.cipherMode.rawValue)\
            $\(baseConfig.ivLength)$
            """
            case let .pbkdf2Based(derivationAlgorithm, baseConfig):
                return """
            $\(baseConfig.version)\
            $pbkdf2\
            $\(derivationAlgorithm.saltLength)\
            $\(derivationAlgorithm.iterations)\
            $\(derivationAlgorithm.pseudoRandomAlgorithm.rawValue)\
            $\(baseConfig.encryptionAlgorithm.rawValue)\
            $\(baseConfig.cipherMode.rawValue)\
            $\(baseConfig.ivLength)$
            """
            case let .noDerivation(baseConfig):
                return """
            $\(baseConfig.version)\
            $noderivation\
            $\(baseConfig.encryptionAlgorithm.rawValue)\
            $\(baseConfig.cipherMode.rawValue)\
            $\(baseConfig.ivLength)$
            """
        }
    }

    static func configuration(from parameters: [String]) -> CryptoConfig? {
        guard [ConfigurationLength.Argon2, ConfigurationLength.PBKDF2, ConfigurationLength.NoDerivation].contains(parameters.count) else {
            return nil
        }
        guard let version = Int(parameters[ConfigurationIndexes.version]),
              let derivationAlgorithm = DerivationAlgorithm(rawValue: parameters[ConfigurationIndexes.derivationAlgorithm]) else {
            return nil
        }
        switch derivationAlgorithm {
            case .pbkdf2:
            return pbkdf2Config(
                from: parameters,
                version: version,
                derivationAlgorithm: derivationAlgorithm
            )
        case .argon2d:
            return argon2dConfig(
                from: parameters,
                version: version,
                derivationAlgorithm: derivationAlgorithm
            )
        case .none:
            return noDerivationConfig(
                from: parameters,
                version: version,
                derivationAlgorithm: derivationAlgorithm
            )
        }
    }

    private static func pbkdf2Config(
        from parameters: [String],
        version: Int,
        derivationAlgorithm: DerivationAlgorithm
    ) -> CryptoConfig? {
        guard let pseudoRandomAlgorithm = PseudoRandomAlgorithm(rawValue: parameters[ConfigurationIndexes.PBKDF2.pseudoRandomAlgorithm]),
              let encryptionAlgorithm = EncryptionAlgorithm(rawValue: parameters[ConfigurationIndexes.PBKDF2.encryptionAlgorithm]),
              let cipherMode = AESMode(rawValue: parameters[ConfigurationIndexes.PBKDF2.cipherMode]),
              let ivLength = Int(parameters[ConfigurationIndexes.PBKDF2.ivLength]),
              let iterations = Int(parameters[ConfigurationIndexes.iterations]),
              let saltLength = Int(parameters[ConfigurationIndexes.saltLength]) else {
            return nil
        }
        let PBKDF2Conf = PBKDF2Configuration(saltLength: saltLength,
                                             iterations: iterations,
                                             pseudoRandomAlgorithm: pseudoRandomAlgorithm)
        let baseConf = BaseConfig(version: version,
                                  derivationAlgorithm: derivationAlgorithm,
                                  encryptionAlgorithm: encryptionAlgorithm,
                                  cipherMode: cipherMode,
                                  ivLength: ivLength)
        return CryptoConfig.pbkdf2Based(derivationAlgorithm: PBKDF2Conf,
                                        baseConfig: baseConf)

    }

    private static func argon2dConfig(
        from parameters: [String],
        version: Int,
        derivationAlgorithm: DerivationAlgorithm
    ) -> CryptoConfig? {
        guard let memoryCost = Int(parameters[ConfigurationIndexes.Argon2.memoryCost]),
              let parallelism = Int(parameters[ConfigurationIndexes.Argon2.parallelism]),
              let encryptionAlgorithm = EncryptionAlgorithm(rawValue: parameters[ConfigurationIndexes.Argon2.encryptionAlgorithm]),
              let cipherMode = AESMode(rawValue: parameters[ConfigurationIndexes.Argon2.cipherMode]),
              let ivLength = Int(parameters[ConfigurationIndexes.Argon2.ivLength]),
              let iterations = Int(parameters[ConfigurationIndexes.iterations]),
              let saltLength = Int(parameters[ConfigurationIndexes.saltLength]) else {
            return nil
        }
        let argon2Conf = Argon2Configuration(iterations: iterations,
                                             memoryCost: memoryCost,
                                             parallelism: parallelism,
                                             saltLength: saltLength)
        let baseConf = BaseConfig(version: version,
                                  derivationAlgorithm: derivationAlgorithm,
                                  encryptionAlgorithm: encryptionAlgorithm,
                                  cipherMode: cipherMode,
                                  ivLength: ivLength)
        return CryptoConfig.argon2dBased(derivationAlgorithm: argon2Conf,
                                         baseConfig: baseConf)
    }

    private static func noDerivationConfig(
        from parameters: [String],
        version: Int,
        derivationAlgorithm: DerivationAlgorithm
    ) -> CryptoConfig? {
        guard let encryptionAlgorithm = EncryptionAlgorithm(rawValue: parameters[ConfigurationIndexes.NoDerivation.encryptionAlgorithm]),
              let cipherMode = AESMode(rawValue: parameters[ConfigurationIndexes.NoDerivation.cipherMode]),
              let ivLength = Int(parameters[ConfigurationIndexes.NoDerivation.ivLength]) else {
            return nil
        }
        let baseConf = BaseConfig(version: version,
                                  derivationAlgorithm: derivationAlgorithm,
                                  encryptionAlgorithm: encryptionAlgorithm,
                                  cipherMode: cipherMode,
                                  ivLength: ivLength)
        return CryptoConfig.noDerivation(baseConfig: baseConf)
    }

    static func legacyMarker(from data: Data) -> CryptoConfig? {
        guard data.count >= DefaultValues.minimumHeaderLength else {
            return nil
        }
        let markerPosition = DefaultValues.legacyMarkerPosition
        let markerOffset = markerPosition + DefaultValues.legacyMarkerLength
        let markerData = data[markerPosition..<min(markerOffset, data.count)]
        guard let markerString = String(data: markerData, encoding: .utf8),
              let marker = LegacyMarker(rawValue: markerString) else {
            return nil
        }
        return marker.cryptoConfig
    }

    static func configuration(from data: Data) -> CryptoConfig? {
                                let legacyMarker = self.legacyMarker(from: data)
        guard legacyMarker == nil else {
            return legacyMarker
        }
                                let separator = UInt8(ascii: "$")
        let splitted = data.split(separator: separator, maxSplits: 9, omittingEmptySubsequences: true)
        guard splitted.count > ConfigurationIndexes.derivationAlgorithm else {
            return LegacyMarker.kwc3.cryptoConfig
        }
        guard let derivationAlgorithmString = String(data: splitted[ConfigurationIndexes.derivationAlgorithm], encoding: .utf8) else {
            return nil
        }
        guard let derivationAlgorithm = DerivationAlgorithm(rawValue: derivationAlgorithmString) else {
            return nil
        }
        let utf8String: (Data) -> String? = { data in
            return String(data: data, encoding: .utf8)
        }
        switch derivationAlgorithm {
            case .argon2d:
                let argon2dParams = splitted[0..<ConfigurationLength.Argon2].compactMap(utf8String)
                return self.configuration(from: argon2dParams)
            case .pbkdf2:
                let pbkdf2Params = splitted[0..<ConfigurationLength.PBKDF2].compactMap(utf8String)
                return self.configuration(from: pbkdf2Params)
            case .none:
                let noDerivationParams = splitted[0..<ConfigurationLength.NoDerivation].compactMap(utf8String)
                return self.configuration(from: noDerivationParams)
        }
    }

    public static func configuration(from string: String) -> CryptoConfig? {
        guard let data = string.data(using: .utf8),
              let configuration = configuration(from: data) else {
            return nil
        }

        return configuration
    }
}
