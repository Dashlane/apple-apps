import Foundation
import CommonCrypto

public final class KeyError: GenericError {}

struct Keys {
    let itemKey: Data
    let hmacKey: Data

    init(withKey key: Data) throws {
        guard let hash = SHA.hash(data: key, using: .sha512) else {
            throw KeyError("SHA512 of key could not be generated")
        }
        self.itemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        self.hmacKey = hash.advanced(by: hash.count / 2)
    }

    var itemKeyBytes: [UInt8] {
        return [UInt8](itemKey)
    }

    var macKeyBytes: [UInt8] {
        return [UInt8](hmacKey)
    }
}

public final class StreamCryptoError: GenericError {}

public class StreamCrypto: StreamTransfer {

        public internal(set) var hmac = [UInt8]()

        var iv = [UInt8]()

        let aesMode: AESMode

        let header = CryptoConfigParser.header(from:
        CryptoConfig.noDerivation(baseConfig: BaseConfig.noDerivation)
        ).data(using: .utf8)!

        var cryptoConfig: CryptoConfig?

        let hmacAlgorithm: HMACAlgorithm

        let keys: Keys

        var hmacContext: CCHmacContext

        var cryptorRef: CCCryptorRef?

                                            public init(source: URL,
                destination: URL,
                key: Data,
                chunkSize: Int = 2048,
                aesMode: AESMode = .cbchmac,
                hmacAlgorithm: HMACAlgorithm = .sha256,
                completionHandler handler: StreamTransferCompletionHandler?) throws {
        let minimumBlockSize = kCCBlockSizeAES128 * 8
        guard chunkSize >= minimumBlockSize else {
            throw StreamCryptoError("Chunk size must be at least \(minimumBlockSize) bytes, currently set to \(chunkSize)")
        }

        self.keys = try Keys(withKey: key)
        var hmacContext = CCHmacContext()
        CCHmacInit(&hmacContext, hmacAlgorithm.CCValue, keys.macKeyBytes, keys.macKeyBytes.count)
        self.hmacContext = hmacContext
        self.aesMode = aesMode
        self.hmacAlgorithm = hmacAlgorithm
        try super.init(source: source,
                       destination: destination,
                       chunkSize: chunkSize,
                       completionHandler: handler)
    }

                func updateHmac(withBytes bytes: [UInt8]) throws {
        CCHmacUpdate(&hmacContext, bytes, bytes.count)
    }

                func endHmac() throws -> [UInt8] {
        var hmac = [UInt8](repeating: 0, count: hmacAlgorithm.digestLength)
        CCHmacFinal(&hmacContext, &hmac)
        return hmac
    }

                        func initCrypto(withOp op: CCOperation, iv: [UInt8]) throws {
        var cryptorRef: CCCryptorRef?
        let status = CCCryptorCreate(op,
                                     CCAlgorithm(kCCAlgorithmAES),
                                     CCOptions(aesMode.CCValue),
                                     keys.itemKeyBytes,
                                     keys.itemKeyBytes.count,
                                     iv,
                                     &cryptorRef)
        guard status == kCCSuccess else {
            throw StreamCryptoError("CCCryptorCreate failed")
        }
        self.cryptorRef = cryptorRef
    }

                    func updateCrypto(withBytes bytes: [UInt8]) throws -> [UInt8] {
        var outBuffer = [UInt8](repeating: 0, count: chunkSize)
        var dataOutMoved = 0
        let status = CCCryptorUpdate(self.cryptorRef,
                                     bytes,
                                     bytes.count,
                                     &outBuffer,
                                     outBuffer.count,
                                     &dataOutMoved)
        guard status == kCCSuccess else {
            throw StreamCryptoError("CCCryptorUpdate failed")
        }
        return Array(outBuffer[0..<dataOutMoved])
    }

                func endCrypto() throws -> [UInt8] {
        var outBuffer = [UInt8](repeating: 0, count: chunkSize)
        var dataOutMoved = 0
        var status = CCCryptorFinal(self.cryptorRef, &outBuffer, outBuffer.count, &dataOutMoved)
        guard status == kCCSuccess else {
            throw StreamCryptoError("CCCryptorUpdate failed")
        }
        status = CCCryptorRelease(self.cryptorRef)
        guard status == kCCSuccess else {
            throw StreamCryptoError("CCCryptorRelease failed")
        }
        return Array(outBuffer[0..<dataOutMoved])
    }
}

extension BaseConfig {
    static var noDerivation: BaseConfig {
        return BaseConfig(version: DefaultValues.supportedVersion,
                          derivationAlgorithm: .none,
                          encryptionAlgorithm: .aes256,
                          cipherMode: .cbchmac,
                          ivLength: DefaultValues.CBCHMAC.ivLength)
    }
}
