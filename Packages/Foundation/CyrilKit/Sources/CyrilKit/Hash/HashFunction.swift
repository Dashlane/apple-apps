import Foundation
import CommonCrypto

public enum HashFunction {
    case sha224
    case sha256
    case sha384
    case sha512

    case md5
    case sha1
}

extension HashFunction {
    var digestLength: Int {
        switch self {
        case .md5:
            return Int(CC_MD5_DIGEST_LENGTH)
        case .sha1:
            return Int(CC_SHA1_DIGEST_LENGTH)
        case .sha224:
            return Int(CC_SHA224_DIGEST_LENGTH)
        case .sha256:
            return Int(CC_SHA256_DIGEST_LENGTH)
        case .sha384:
            return Int(CC_SHA384_DIGEST_LENGTH)
        case .sha512:
            return Int(CC_SHA512_DIGEST_LENGTH)

        }
    }
}

extension HashFunction {
    private var hashFunction: (_ data: UnsafeRawPointer?, _ len: CC_LONG, _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?? {
        switch self {
        case .md5:
            return CC_MD5
        case .sha1:
            return CC_SHA1
        case .sha224:
            return CC_SHA224
        case .sha256:
            return CC_SHA256
        case .sha384:
            return CC_SHA384
        case .sha512:
            return CC_SHA512
        }
    }

    func hash<R: ContiguousBytes> (of data: R) -> Data {
        var derivedKey = [UInt8](repeating: 0, count: digestLength)
        derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            data.withUnsafeBytes { dataBytes in
                _ = hashFunction(dataBytes.baseAddress, CC_LONG(dataBytes.count), derivedKeyBytes.baseAddress?.bindMemory(to: UInt8.self, capacity: digestLength))
            }
        }
        return Data(bytes: derivedKey, count: digestLength)
    }
}

extension ContiguousBytes {
                public func digest(using algorithm: HashFunction) -> Data {
        return algorithm.hash(of: self)
    }

                public func md5() -> Data {
        digest(using: .md5)
    }

                public func sha1() -> Data {
        digest(using: .sha1)
    }

                public func sha224() -> Data {
        digest(using: .sha224)
    }

                public func sha256() -> Data {
        digest(using: .sha256)
    }

                public func sha384() -> Data {
        digest(using: .sha384)
    }

                public func sha512() -> Data {
        digest(using: .sha512)
    }
}
