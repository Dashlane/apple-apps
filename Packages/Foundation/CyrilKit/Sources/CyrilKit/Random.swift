import Foundation

public extension Data {
                    static func random(ofSize size: Int) -> Data {
        var bytes = [Int8](repeating: 0, count: size)
        _ = SecRandomCopyBytes(kSecRandomDefault, size, &bytes)
        return .init(bytes: bytes, count: size)
    }
}

public extension Array where Element == UInt8 {
                    static func random(ofSize size: Int) -> [UInt8] {
        var bytesArray = [UInt8](repeating: 0, count: size)
        _ = SecRandomCopyBytes(kSecRandomDefault, size, &bytesArray)
        return bytesArray
    }
}
