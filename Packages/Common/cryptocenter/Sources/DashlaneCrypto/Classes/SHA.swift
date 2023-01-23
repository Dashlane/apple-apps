import Foundation
import CommonCrypto

public struct SHA {

        public static func hash(text: String, using algorithm: PseudoRandomAlgorithm) -> Data? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        return self.hash(data: data, using: algorithm)
    }

    public static func hash(data: Data, using algorithm: PseudoRandomAlgorithm) -> Data? {
        var buffer = [UInt8].init(repeating: 0, count: algorithm.digestLength)
        _ = data.withUnsafeBytes {
            algorithm.hash($0.baseAddress!, CC_LONG(data.count), &buffer)
        }
        return Data(buffer)
    }

}
