import Foundation

extension Definition {

  public enum `OtpType`: String, Encodable, Sendable {
    case `hotp`
    case `totp`
  }
}
