import Foundation

extension Definition {

  public enum `AuthenticatorPushType`: String, Encodable, Sendable {
    case `otpCode` = "otp_code"
  }
}
