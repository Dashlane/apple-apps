import Foundation
import SwiftTreats
import DashTypes

public enum CryptoCenterError: Error {
    case keyNotProvided
    case passwordNotProvided
    case keyOrPasswordNotProvided
}


public struct CryptoCenter {
    
        public let config: CryptoConfig
    
        public var header: String {
        return CryptoConfigParser.header(from: config)
    }
    
        public var derivationKeyCacheDelegate: DerivationKeyCacheDelegate?
    
            public init(configuration: CryptoConfig) {
        self.config = configuration
    }
    
            public init?(from configurationString: String) {
        guard let configuration = CryptoConfigParser.configuration(from: configurationString) else {
            return nil
        }
        self.init(configuration: configuration)
    }
    
            public init?(from data: Data) {
        guard let configuration = CryptoConfigParser.configuration(from: data) else {
            return nil
        }
        self.init(configuration: configuration)
    }
    
                        public func encrypt(data: Data,
                        with secret: EncryptionSecret) throws -> Data? {
        try self.encrypt(data: data, with: secret, initialisationVector: nil)
    }
    
                        public func decrypt(data: Data,
                        with secret: EncryptionSecret) throws -> Data? {
        switch secret {
        case .key(let key):
            return try self.decrypt(data: data, withPassword: nil, derivedKey: key)
        case .password(let password):
            return try self.decrypt(data: data, withPassword: password, derivedKey: nil)
        }
    }
}

internal extension CryptoCenter {
    
        func encrypt(data: Data,
                        with secret: EncryptionSecret,
                        initialisationVector: Data?) throws -> Data? {

        switch secret {
        case .key(let key):
            return try self.encrypt(data: data, withPassword: nil, derivedKey: key, initialisationVector: initialisationVector)
        case .password(let password):
            return try self.encrypt(data: data, withPassword: password, derivedKey: nil, initialisationVector: initialisationVector)
        }
    }

    func produceSalt(ofSize size: UInt) -> Data {
        guard let salt = derivationKeyCacheDelegate?.fixedSalt(ofSize: size) else {
            let salt = Data(Random.randomByteArray(ofSize: config.saltLength))
            derivationKeyCacheDelegate?.saveFixedSalt(salt)
            return salt
        }
        return salt
    }
    
    func saveFixedSaltIfNotSetAlready(_ salt: Data) {
        guard derivationKeyCacheDelegate?.fixedSalt(ofSize: UInt(salt.count)) == nil else {
            return
        }
        derivationKeyCacheDelegate?.saveFixedSalt(salt)
    }

    func CBCHMACEncrypt(data: Data,
                        withPassword password: String,
                        andInitialisationVector: Data? = nil) -> Data? {
        let salt = [UInt8](produceSalt(ofSize: UInt(config.saltLength)))
        guard let derivedKey = self.derivedKey(from: password, salt: salt) else {
            return nil
        }
        guard let hash = SHA.hash(data: derivedKey, using: .sha512) else {
            return nil
        }
        let newItemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        let macKey = hash.advanced(by: hash.count / 2)
        let iv: [UInt8]
        if let existingIV = andInitialisationVector {
            iv = [UInt8](existingIV)
        } else {
            iv = Random.randomByteArray(ofSize: config.ivLength)
        }
        guard let AESEncryptedData = AES.encrypt(data: data, withKey: newItemKey, mode: .cbc, initializationVector: iv) else {
            return nil
        }
        guard let hmacSHA2Hash = HMAC.hash(of: iv + AESEncryptedData, withKey: macKey, using: .sha256) else {
            return nil
        }
        return header.data(using: .utf8)! + salt + iv + hmacSHA2Hash + AESEncryptedData
    }

    func CBCHMACDecrypt(data: Data,
                        withPassword password: String) -> Data? {
        guard let payloadString = header.data(using: .utf8) else {
            return nil
        }
        var index = payloadString.count
        let salt = data[index..<index + config.saltLength]
        saveFixedSaltIfNotSetAlready(salt)
        index += config.saltLength
        let iv = data[index..<index + config.ivLength]
        index += config.ivLength
        let hmacSHA2Hash = data[index..<index + DefaultValues.CBCHMAC.HMACSHA2Length]
        index += DefaultValues.CBCHMAC.HMACSHA2Length
        let encryptedData = data[index..<data.count]
        guard let derivedKey = self.derivedKey(from: password, salt: [UInt8](salt)) else {
            return nil
        }
        guard let hash = SHA.hash(data: derivedKey, using: .sha512) else {
            return nil
        }
        let newItemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        let macKey = hash.advanced(by: hash.count / 2)
        let computedHMACSHA2 = HMAC.hash(of: iv + encryptedData, withKey: macKey, using: .sha256)
        guard hmacSHA2Hash.hexadecimalString == computedHMACSHA2!.hexadecimalString else {
            return nil
        }
        return AES.decrypt(data: encryptedData, withKey: newItemKey, mode: .cbc, initializationVector: [UInt8](iv))
    }

    func CBCHMACEncrypt(data: Data,
                        withKey key: Data,
                        andInitialisationVector: Data? = nil) -> Data? {
        guard let hash = makeCBCHMACKey(data: key) else { return nil }
        let newItemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        let macKey = hash.advanced(by: hash.count / 2)
        let iv: [UInt8]
        if let existingIV = andInitialisationVector {
            iv = [UInt8](existingIV)
        } else {
            iv = Random.randomByteArray(ofSize: config.ivLength)
        }
        guard let AESEncryptedData = AES.encrypt(data: data, withKey: newItemKey, mode: .cbc, initializationVector: iv) else {
            return nil
        }
        guard let hmacSHA2Hash = HMAC.hash(of: iv + AESEncryptedData, withKey: macKey, using: .sha256) else {
            return nil
        }
        return header.data(using: .utf8)! + iv + hmacSHA2Hash + AESEncryptedData
    }

    func CBCHMACDecrypt(data: Data,
                        withKey key: Data) -> Data? {
        guard let payloadString = header.data(using: .utf8) else {
            return nil
        }
        var index = payloadString.count
        index += config.saltLength
        let iv = data[index..<index + config.ivLength]
        index += config.ivLength
        let hmacSHA2Hash = data[index..<index + DefaultValues.CBCHMAC.HMACSHA2Length]
        index += DefaultValues.CBCHMAC.HMACSHA2Length
        let encryptedData = data[index..<data.count]

        guard let hash = makeCBCHMACKey(data: key) else { return nil }

        let newItemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        let macKey = hash.advanced(by: hash.count / 2)
        let computedHMACSHA2 = HMAC.hash(of: iv + encryptedData, withKey: macKey, using: HMACAlgorithm.sha256)
        guard hmacSHA2Hash == computedHMACSHA2 else {
            return nil
        }
        return AES.decrypt(data: encryptedData, withKey: newItemKey, mode: .cbc, initializationVector: [UInt8](iv))
    }
}

private extension CryptoCenter {
    func makeCBCHMACKey(data: Data?) -> Data? {
        guard let data = data else { return nil }

        if self.config.cipherMode == .cbchmac64 {
            return data
        } else {
            return SHA.hash(data: data, using: .sha512)
        }
    }
    
                        private func derivedKey(from password: String, salt: [UInt8]) -> Data? {
        
        if let key = derivationKeyCacheDelegate?.value(forConfig: config, password: password, salt: Data(salt)) {
            return key
        }
        
        switch config {
            case .argon2dBased(let argon2Conf, _):
                guard let key = Derivation.argon2d(of: password,
                                                   addingSalt: salt,
                                                   memoryCost: argon2Conf.memoryCost) else {
                                                    return nil
                }
                derivationKeyCacheDelegate?.set(value: key, forConfig: config, password: password, salt: Data(salt))
                return key
            case .pbkdf2Based(let PBKDF2Conf, _):
                guard let key = Derivation.PBKDF2(of: password,
                                                  using: PBKDF2Conf.pseudoRandomAlgorithm,
                                                  derivedKeyLength: DefaultValues.CBCHMAC.derivedKeyLength,
                                                  salt: salt,
                                                  numberOfIterations: PBKDF2Conf.iterations) else {
                                                    return nil
                }
                derivationKeyCacheDelegate?.set(value: key, forConfig: config, password: password, salt: Data(salt))
                return key
            case .noDerivation:
                return Data(base64Encoded: password.toBase64())
            case .kwc3:
                let passwordBytes = KWC3.encodePassword(password)
                guard let key = Derivation.PBKDF2(of: passwordBytes,
                                                  using: DefaultValues.KWC3.algorithm,
                                                  derivedKeyLength: DefaultValues.KWC3.derivedKeyLength,
                                                  salt: salt,
                                                  numberOfIterations: DefaultValues.KWC3.numberOfIterations) else {
                                                    return nil
                }
                derivationKeyCacheDelegate?.set(value: key, forConfig: config, password: password, salt: Data(salt))
                return key
            case .kwc5:
                return nil
        }
    }

    private func encrypt(data: Data,
                         withPassword password: String) throws -> Data? {
        return try self.encrypt(data: data, withPassword: password, derivedKey: nil)
    }

    private func encrypt(data: Data,
                         withDerivedKey derivedKey: Data) throws -> Data? {
        return try self.encrypt(data: data, withPassword: nil, derivedKey: derivedKey)
    }

    private func encrypt(data: Data,
                         withPassword password: String? = nil,
                         derivedKey: Data? = nil,
                         initialisationVector: Data? = nil) throws -> Data? {
        switch config {
        case .kwc3:
            guard let password = password else {
                throw CryptoCenterError.passwordNotProvided
            }
            let salt = [UInt8](produceSalt(ofSize: UInt(config.saltLength)))
                guard let derivedKey = self.derivedKey(from: password, salt: salt) else {
                    return nil
                }
            return KWC3.encrypt(data: data, salt: Data(salt), derivedKey: derivedKey) 
        case .kwc5:
            guard let derivedKey = derivedKey else {
                throw CryptoCenterError.keyNotProvided
            }
            return KWC5.encrypt(data: data, withDerivedKey: derivedKey) 
        default:
            break
        }
        switch config.cipherMode {
            case .cbchmac, .cbchmac64:
            if let password = password {
                return self.CBCHMACEncrypt(data: data, withPassword: password, andInitialisationVector: initialisationVector)
            }
            if let key = derivedKey {
                return self.CBCHMACEncrypt(data: data, withKey: key, andInitialisationVector: initialisationVector)
            }
            throw CryptoCenterError.keyOrPasswordNotProvided
        default:
            return nil
        }
    }

    private func decrypt(data: Data,
                         withPassword password: String? = nil,
                         derivedKey: Data? = nil) throws -> Data? {
        switch config {
        case .kwc3:
            guard let password = password else {
                throw CryptoCenterError.passwordNotProvided
            }
            guard data.count >= DefaultValues.KWC3.saltLength else {
                return nil
            }
            let salt = [UInt8](data[0..<DefaultValues.KWC3.saltLength])
            guard let derivedKey = self.derivedKey(from: password, salt: salt) else {
                return nil
            }
            return KWC3.decrypt(data: data, withDerivedKey: derivedKey) 
        case .kwc5:
            guard let derivedKey = derivedKey else {
                throw CryptoCenterError.keyNotProvided
            }
            return KWC5.decrypt(data: data, withDerivedKey: derivedKey) 
        default:
            break
        }
        switch config.cipherMode {
            case .cbchmac, .cbchmac64:
            if let password = password {
                return self.CBCHMACDecrypt(data: data, withPassword: password)
            }
            if let key = derivedKey {
                return self.CBCHMACDecrypt(data: data, withKey: key)
            }
            throw CryptoCenterError.keyOrPasswordNotProvided
        default:
            return nil
        }
    }
}
