import Foundation

extension Definition {

public enum `OtpType`: String, Encodable {
case `hotp`
case `totp`
}
}