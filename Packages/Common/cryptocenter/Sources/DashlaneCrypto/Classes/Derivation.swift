import Foundation
import CommonCrypto

public class SHA1Hasher {

    private let context = UnsafeMutablePointer<CC_SHA1_CTX>.allocate(capacity: 1)

    public required init() {
        CC_SHA1_Init(context)
    }

    public func reset() {
        CC_SHA1_Init(context)
    }

    public func update(_ data: Data) {
        _ = data.withUnsafeBytes {
            CC_SHA1_Update(context, $0.baseAddress!, CC_LONG(data.count))
        }
    }

    public func final() -> Data {
        var digest = Array<UInt8>(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1_Final(&digest, context)
        return Data(digest)
    }
}

public struct Derivation {

            static public func SharingV1BytesToKey(salt: Data, data: Data) -> (key: Data, iv: Data) {

        let count = 5

        let PKCS5_SALT_LEN = 8
        if salt.count != PKCS5_SALT_LEN {
            preconditionFailure("salt should be 8 bytes")
        }

        var m = Data()
        var buf = Data()
        let h = SHA1Hasher()

        while buf.count < 48 {
            h.reset()
            h.update(m)
            h.update(data)
            h.update(salt)
            var temp = h.final()
            for _ in 1 ..< count {
                h.reset()
                h.update(temp)
                temp = h.final()
            }

            m = temp
            buf.append(m)
        }

        let key = buf.prefix(upTo: 32)
        let iv = buf.subdata(in: 32 ..< 48)
        return (key, iv)
    }

    static public func PBKDF2(of passwordBytes: [CChar],
                             using algorithm: PseudoRandomAlgorithm,
                             derivedKeyLength: Int,
                             salt: [UInt8] = Random.generate16BytesSalt(),
                             numberOfIterations: Int) -> Data? {
        var derivedKey = [UInt8](repeating: 0, count: derivedKeyLength)
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                             passwordBytes,
                             passwordBytes.count,
                             salt,
                             salt.count,
                             algorithm.CCValue,
                             UInt32(numberOfIterations),
                             &derivedKey,
                             derivedKeyLength)
        return Data(derivedKey)
    }

    static public func PBKDF2(of password: String,
                             using algorithm: PseudoRandomAlgorithm,
                             derivedKeyLength: Int,
                             salt: [UInt8] = Random.generate16BytesSalt(),
                             numberOfIterations: Int) -> Data? {
        let passwordCharArray = [CChar](password.utf8CString)
        let passwordBytes = (passwordCharArray.last == 0) ? [CChar](passwordCharArray[0..<passwordCharArray.count - 1]) : passwordCharArray
        return PBKDF2(of: passwordBytes,
                      using: algorithm,
                      derivedKeyLength: derivedKeyLength,
                      salt: salt,
                      numberOfIterations: numberOfIterations)
    }

    static public func argon2d(of password: String) -> Data? {
        let argon2Wrapper = Argon2()
        return argon2Wrapper.argon2dHash(of: password)
    }

    static public func argon2d(of password: String, addingSalt salt: [UInt8], memoryCost: Int) -> Data? {
        let argon2Wrapper = Argon2(timeCost: DefaultValues.Argon2d.timeCost,
                                   memoryCost: UInt32(memoryCost),
                                   parallelism: DefaultValues.Argon2d.parallelism)
        return argon2Wrapper.argon2dHash(of: password,
                                         addingSalt: salt,
                                         derivedKeyLength: DefaultValues.Argon2d.derivedKeyLength)
    }

}
