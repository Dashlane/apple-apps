import Foundation

extension Definition {

  public enum `AuthenticatorUserVerificationSource`: String, Encodable, Sendable {
    case `passkeyLogin` = "passkey_login"
    case `passkeyRegistration` = "passkey_registration"
  }
}
