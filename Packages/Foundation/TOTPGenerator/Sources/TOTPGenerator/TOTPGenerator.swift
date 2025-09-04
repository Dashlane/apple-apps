import CryptoKit
import Foundation

public final class TOTPGenerator {

  private static func code<H: HashFunction>(
    with type: OTPType,
    digits: Int,
    algorithm: H.Type,
    secret: Data,
    date: Date,
    currentCounter: UInt64? = nil
  ) -> String {

    let counter = type.counterValue(for: date, currentCounter: currentCounter)

    var bigCounter = counter.bigEndian
    let counterData = Data(bytes: &bigCounter, count: MemoryLayout<UInt64>.size)

    let key = SymmetricKey(data: secret)
    let hash = Data(HMAC<H>.authenticationCode(for: counterData, using: key))

    let offset = Int((hash.last ?? 0x00) & 0x0f)

    let number: UInt32 =
      ((UInt32(hash[offset]) & 0x7f) << 24 | (UInt32(hash[offset + 1]) << 16)
        | (UInt32(hash[offset + 2]) << 8) | UInt32(hash[offset + 3]))

    let otp = String(number % UInt32(pow(10.0, Double(digits))))

    let padding = String(repeating: "0", count: digits - otp.count)

    return padding + otp
  }

  private static func code(
    with type: OTPType, digits: Int, algorithm: HashAlgorithm, secret: Data, for date: Date,
    currentCounter: UInt64? = nil
  ) -> String {

    switch algorithm {
    case .sha1:
      return code(
        with: type,
        digits: digits,
        algorithm: Insecure.SHA1.self,
        secret: secret,
        date: date)

    case .sha256:
      return code(
        with: type,
        digits: digits,
        algorithm: SHA256.self,
        secret: secret,
        date: date)

    case .sha512:
      return code(
        with: type,
        digits: digits,
        algorithm: SHA512.self,
        secret: secret,
        date: date)
    }
  }

  public func timeRemaining(in duration: TimeInterval) -> TimeInterval {
    let time = Date().timeIntervalSince1970
    return ceil(time / duration) * duration - time
  }

  public static func timeRemaining(in duration: TimeInterval = 30) -> TimeInterval {
    let time = Date().timeIntervalSince1970
    return ceil(time / duration) * duration - time
  }

  public static func progress(in duration: TimeInterval = 30) -> TimeInterval {
    let remainingTime = timeRemaining(in: duration)
    return (duration - remainingTime) / duration
  }

  public static func generate(
    with type: OTPType, for date: Date, digits: Int, algorithm: HashAlgorithm, secret: Data,
    currentCounter: UInt64? = nil
  ) -> String {
    return TOTPGenerator.code(
      with: type, digits: digits, algorithm: algorithm, secret: secret, for: date,
      currentCounter: currentCounter)
  }

}

public enum HashAlgorithm: String, Codable, Sendable {
  case sha1
  case sha256
  case sha512
}
