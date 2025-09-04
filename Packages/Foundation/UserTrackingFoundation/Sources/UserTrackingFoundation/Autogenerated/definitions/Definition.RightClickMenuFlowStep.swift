import Foundation

extension Definition {

  public enum `RightClickMenuFlowStep`: String, Encodable, Sendable {
    case `clickDashlane` = "click_dashlane"
    case `displayMenu` = "display_menu"
    case `selectVaultItem` = "select_vault_item"
  }
}
