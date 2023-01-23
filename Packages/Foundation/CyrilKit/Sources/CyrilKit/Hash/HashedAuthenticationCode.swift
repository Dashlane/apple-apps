import Foundation
import CommonCrypto

public struct HashedAuthenticationCodeProducer: AuthenticationCodeProducer {
    public let key: SymmetricKey
    public let variant: HashFunction
    
    public init(key: SymmetricKey, variant: HashFunction) {
        self.key = key
        self.variant = variant
    }
    
        public func authenticationCode(for data: Data) -> Data {
        let hashBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: variant.digestLength)
        defer { hashBytes.deallocate() }
        
        data.withUnsafeBytes { dataBytes -> Void in
            key.withUnsafeBytes { keyBytes -> Void in
                CCHmac(variant.hmacAlgorithm, keyBytes.baseAddress, key.count, dataBytes.baseAddress, data.count, hashBytes)
            }
        }
        
        return Data(bytes: hashBytes, count: variant.digestLength)
    }
}

public typealias HMAC = HashedAuthenticationCodeProducer

private extension HashFunction {
    var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
            case .md5:
                return CCHmacAlgorithm(kCCHmacAlgMD5)
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
}
