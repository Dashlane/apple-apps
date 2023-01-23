import Foundation
import CommonCrypto

struct HashProvider {
    
    static func hmacUsingSha256(of data: Data, withKey key: Data) -> Data? {
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
               [UInt8](key),
               key.count,
               [UInt8](data),
               data.count,
               &hash)
        return Data(hash)
    }
    
    static func shaUsingSha256(of data: Data) -> Data? {
        var buffer = [UInt8].init(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { unsafeRawBufferPointer in
            let baseRawPointer = unsafeRawBufferPointer.baseAddress
            let basePointer = baseRawPointer!.bindMemory(to: UInt8.self,
                                                         capacity: MemoryLayout<UInt8>.size)
            CC_SHA256(basePointer, CC_LONG(data.count), &buffer)
        }
        return Data(buffer)
    }
}
