import Foundation

public extension Data {

    var hexadecimalString: String {
        return map {
            String.init(format: "%02hhx", $0)
        }.joined()
    }

    var bytes: [UInt8] {
        return [UInt8](self)
    }

    init?(hexadecimalString: String) {
        guard hexadecimalString.lengthOfBytes(using: .utf8) % 2 == 0 else {
            return nil
        }
        self.init()
        let byteArray: [UInt8] = stride(from: 0, to: hexadecimalString.count, by: 2).compactMap { distance in
            let index = hexadecimalString.index(hexadecimalString.startIndex, offsetBy: distance)
            return UInt8(hexadecimalString[index..<hexadecimalString.index(index, offsetBy: 2)], radix: 16)
        }
        self = Data( byteArray)
    }
}
