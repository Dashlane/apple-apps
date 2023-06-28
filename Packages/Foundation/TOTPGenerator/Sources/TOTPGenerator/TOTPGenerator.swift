import Foundation
import CryptoKit

public final class TOTPGenerator {

    private class func code(with type: OTPType, digits: Int, algorithm: HashAlgorithm, secret: Data, for date: Date, currentCounter: UInt64? = nil) -> String {

        let counter = type.counterValue(for: date, currentCounter: currentCounter)

                var bigCounter = counter.bigEndian

                let counterData = Data(bytes: &bigCounter, count: MemoryLayout<UInt64>.size)
        let hash: Data

        let key = SymmetricKey(data: secret)

        func createData(_ ptr: UnsafeRawBufferPointer) -> Data {
            Data(bytes: ptr.baseAddress!, count: algorithm.hashLength)
        }

        switch algorithm {
        case .sha1:
            hash = CryptoKit.HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key).withUnsafeBytes(createData)
        case .sha256:
            hash = CryptoKit.HMAC<SHA256>.authenticationCode(for: counterData, using: key).withUnsafeBytes(createData)
        case .sha512:
            hash = CryptoKit.HMAC<SHA512>.authenticationCode(for: counterData, using: key).withUnsafeBytes(createData)
        }

        var truncatedHash = hash.withUnsafeBytes { pointer -> UInt32 in
            let offset = pointer[hash.count - 1] & 0xf
            let truncatedHashPointer = pointer.baseAddress! + Int(offset)
            return UInt32(truncatedHashPointer.bindMemory(to: UInt32.self, capacity: 1).pointee)
        }

        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash &= 0x7fffffff

                        let finalHash = Decimal(truncatedHash).modulo(pow(10.0, digits))
        let result = Int(truncating: NSDecimalNumber(decimal: finalHash))
        return String(format: "%0*u", digits, result)
    }

    public func timeRemaining(in duration: TimeInterval) -> TimeInterval {
        let time = Date().timeIntervalSince1970
        return ceil(time / duration) * duration - time
    }

    public class func timeRemaining(in duration: TimeInterval = 30) -> TimeInterval {
        let time = Date().timeIntervalSince1970
        return ceil(time / duration) * duration - time
    }

    public class func generate(with type: OTPType, for date: Date, digits: Int, algorithm: HashAlgorithm, secret: Data, currentCounter: UInt64? = nil) -> String {
        return TOTPGenerator.code(with: type, digits: digits, algorithm: algorithm, secret: secret, for: date, currentCounter: currentCounter)
    }

}

extension Decimal {
    func modulo(_ other: Decimal) -> Decimal {
        var quotient = self / other
        var result: Decimal = 0
        NSDecimalRound(&result, &quotient, 0, .down)
        return self - (other * result)
    }
}

public enum HashAlgorithm: String, Codable {
    case sha1
        case sha256
        case sha512

    var hashLength: Int {
        switch self {
        case .sha1:
            return Insecure.SHA1.byteCount
        case .sha256:
            return SHA256.byteCount
        case .sha512:
            return SHA512.byteCount
        }
    }
}
