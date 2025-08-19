import Foundation

extension Definition {

  public enum `VerificationMode`: String, Encodable, Sendable {
    case `authenticatorApp` = "authenticator_app"
    case `emailToken` = "email_token"
    case `none`
    case `otp1`
    case `otp2`
  }
}
