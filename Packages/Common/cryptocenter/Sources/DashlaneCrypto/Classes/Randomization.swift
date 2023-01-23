import Foundation

public struct Random {

        static func randomByteArray(ofSize size: Int) -> [UInt8] {
        var bytesArray = [UInt8](repeating: 0, count: size)
        _ = SecRandomCopyBytes(kSecRandomDefault, size, &bytesArray)
        return bytesArray
    }

    public static func randomData(ofSize size: Int) -> Data {
        return Data( randomByteArray(ofSize: size))
    }

    static func generate32BytesSalt() -> [UInt8] {
        return self.randomByteArray(ofSize: 32)
    }

    public static func generate16BytesSalt() -> [UInt8] {
        return self.randomByteArray(ofSize: 16)
    }

}
