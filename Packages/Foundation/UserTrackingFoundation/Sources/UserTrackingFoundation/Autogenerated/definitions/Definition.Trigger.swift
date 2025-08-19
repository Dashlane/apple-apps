import Foundation

extension Definition {

  public enum `Trigger`: String, Encodable, Sendable {
    case `accountCreation` = "account_creation"
    case `changeMasterPassword` = "change_master_password"
    case `changeTeam` = "change_team"
    case `initialLogin` = "initial_login"
    case `login`
    case `manual`
    case `periodic`
    case `push`
    case `save`
    case `saveMeta` = "save_meta"
    case `settingsChange` = "settings_change"
    case `sharing`
    case `wake`
  }
}
