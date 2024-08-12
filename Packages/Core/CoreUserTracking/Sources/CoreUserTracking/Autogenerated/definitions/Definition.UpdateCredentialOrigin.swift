import Foundation

extension Definition {

  public enum `UpdateCredentialOrigin`: String, Encodable, Sendable {
    case `csvImport` = "csv_import"
    case `manual`
    case `passwordChanger` = "password_changer"
    case `passwordHistory` = "password_history"
    case `secureVaultImport` = "secure_vault_import"
  }
}
