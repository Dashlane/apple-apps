import Foundation

extension Definition {

  public enum `CryptoMigrationType`: String, Encodable, Sendable {
    case `masterPasswordChange` = "master_password_change"
    case `masterPasswordToSso` = "master_password_to_sso"
    case `migrateLegacy` = "migrate_legacy"
    case `settingsApplyLocally` = "settings_apply_locally"
    case `settingsChange` = "settings_change"
    case `ssoToMasterPassword` = "sso_to_master_password"
    case `teamEnforced` = "team_enforced"
  }
}
