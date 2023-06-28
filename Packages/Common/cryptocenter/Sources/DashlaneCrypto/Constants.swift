import Foundation
import CommonCrypto

struct DefaultValues {

    static let minimumHeaderLength = 34
    static let legacyMarkerPosition = 32
    static let legacyMarkerLength = 4

    static let supportedVersion = 1

    struct Argon2d {
        static let derivedKeyLength         = 32
        static let timeCost: UInt32         = 3
        static let memoryCost: UInt32       = 1 << 15
        static let parallelism: UInt32      = 2
    }

    struct KWC3 {
        static let ivLength                 = 32
        static let saltLength               = 32
        static let derivedKeyLength         = 32
        static let numberOfIterations       = 10204
        static let algorithm                = PseudoRandomAlgorithm.sha1
        static let tag                      = "KWC3".data(using: .utf8)!
    }

    struct KWC5 {
        static let ivLength                 = 16
        static let placeholderSize          = 16
        static let tag                      = "KWC5".data(using: .utf8)!
    }

    struct CBCHMAC {
        static let ivLength                 = 16
        static let saltLength               = 16
        static let derivedKeyLength         = 32
        static let numberOfIterations       = 200000
        static let algorithm                = HMACAlgorithm.sha256
        static let HMACSHA2Length           = 32
    }

    struct AES {
        static let defaultBufferSize        = 4096
    }

    struct RSA {
        static let keySize = 2048
    }

}

public enum LegacyMarker: String {
    case kwc3 = "KWC3"
    case kwc5 = "KWC5"

    var cryptoConfig: CryptoConfig {
        switch self {
        case .kwc3:
            return .kwc3
        case .kwc5:
            return .kwc5
        }
    }
}

public enum DerivationAlgorithm: String, Equatable {
    case pbkdf2
    case argon2d
    case none = "noderivation"
}

public enum EncryptionAlgorithm: String {
    case aes256 
}

public enum PseudoRandomAlgorithm: String {

    case sha1   = "sha1"
    case sha224 = "sha224"
    case sha256 = "sha256"
    case sha384 = "sha384"
    case sha512 = "sha512"

    var CCValue: CCPseudoRandomAlgorithm {
        switch self {
        case .sha1:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1)
        case .sha224:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA224)
        case .sha256:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
        case .sha384:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA384)
        case .sha512:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512)
        }
    }

    var digestLength: Int {
        switch self {
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

    var hash: (_ data: UnsafeRawPointer?, _ len: CC_LONG, _ md: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8>?? {
        switch self {
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

}

public enum HMACAlgorithm {

    case sha1
    case sha224
    case sha256
    case sha384
    case sha512

    var CCValue: CCHmacAlgorithm {
        switch self {
        case .sha1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha224:
            return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .sha256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384:
            return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        }
    }

    var digestLength: Int {
        switch self {
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

public enum AESMode: String {
    case cbc
    case cbchmac
    case cbchmac64
    case gcm 

    var CCValue: Int {
        switch self {
            case .cbc, .cbchmac, .cbchmac64:
            return kCCOptionPKCS7Padding
        case .gcm: 
            return 0  
        }
    }
}

struct RSAKeyConstants {
    static let publicKeyHeader = "-----BEGIN RSA PUBLIC KEY-----"
    static let publicKeyFooter = "-----END RSA PUBLIC KEY-----"
    static let privateKeyHeader = "-----BEGIN RSA PRIVATE KEY-----"
    static let privateKeyFooter = "-----END RSA PRIVATE KEY-----"
}

enum RSAError: Error {
    case keyPairGeneration
}

struct ConfigurationLength {
    static let PBKDF2 = 8
    static let Argon2 = 9
    static let NoDerivation = 5
}

struct ConfigurationIndexes {

    static let version = 0
    static let derivationAlgorithm = 1
    static let saltLength = 2
    static let iterations = 3

        struct PBKDF2 {
        static let pseudoRandomAlgorithm = 4
        static let encryptionAlgorithm = 5
        static let cipherMode = 6
        static let ivLength = 7
    }

        struct Argon2 {
        static let memoryCost = 4
        static let parallelism = 5
        static let encryptionAlgorithm = 6
        static let cipherMode = 7
        static let ivLength = 8
    }

    struct NoDerivation {
        static let encryptionAlgorithm = 2
        static let cipherMode = 3
        static let ivLength = 4
    }

}
