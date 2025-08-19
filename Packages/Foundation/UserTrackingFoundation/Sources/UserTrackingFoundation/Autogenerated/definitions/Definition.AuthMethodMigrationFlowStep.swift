import Foundation

extension Definition {

  public enum `AuthMethodMigrationFlowStep`: String, Encodable, Sendable {
    case `alertMpCompromised` = "alert_mp_compromised"
    case `alertSsoEnabled` = "alert_sso_enabled"
    case `error`
    case `proceedToChangeToMpless` = "proceed_to_change_to_mpless"
    case `skipOptionForCompromisedMp` = "skip_option_for_compromised_mp"
    case `startChangeOfMp` = "start_change_of_mp"
    case `startChangeToMpless` = "start_change_to_mpless"
    case `startMigrationToMpless` = "start_migration_to_mpless"
    case `startMigrationToSso` = "start_migration_to_sso"
    case `successfulMigrationToMpless` = "successful_migration_to_mpless"
    case `successfulMigrationToSso` = "successful_migration_to_sso"
    case `viewOptionsForCompromisedMp` = "view_options_for_compromised_mp"
  }
}
