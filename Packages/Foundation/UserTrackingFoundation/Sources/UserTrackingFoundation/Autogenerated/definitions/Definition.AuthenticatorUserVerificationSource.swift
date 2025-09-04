import Foundation

extension Definition {

  public enum `AuthenticatorUserVerificationSource`: String, Encodable, Sendable {
    case `autofill`
    case `copyVaultItem` = "copy_vault_item"
    case `passkeyLogin` = "passkey_login"
    case `passkeyRegistration` = "passkey_registration"
  }
}
