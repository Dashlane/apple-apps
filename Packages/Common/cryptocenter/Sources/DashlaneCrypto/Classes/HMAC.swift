import Foundation
import CommonCrypto

public struct HMAC {

        public static func hash(of data: Data, withKey key: Data, using algorithm: HMACAlgorithm = .sha256) -> Data? {
        var hash = [UInt8](repeating: 0, count: algorithm.digestLength)
        CCHmac(algorithm.CCValue,
               [UInt8](key),
               key.count,
               [UInt8](data),
               data.count,
               &hash)
        return Data( hash)
    }

}
