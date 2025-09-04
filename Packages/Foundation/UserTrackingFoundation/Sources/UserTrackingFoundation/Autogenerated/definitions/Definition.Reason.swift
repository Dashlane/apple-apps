import Foundation

extension Definition {

  public enum `Reason`: String, Encodable, Sendable {
    case `changeMasterPassword` = "change_master_password"
    case `editSettings` = "edit_settings"
    case `login`
    case `unlockApp` = "unlock_app"
    case `unlockItem` = "unlock_item"
  }
}
