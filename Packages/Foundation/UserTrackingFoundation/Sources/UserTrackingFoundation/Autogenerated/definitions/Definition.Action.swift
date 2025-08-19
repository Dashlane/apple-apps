import Foundation

extension Definition {

  public enum `Action`: String, Encodable, Sendable {
    case `add`
    case `addCustomField` = "add_custom_field"
    case `connect`
    case `delete`
    case `deleteCustomField` = "delete_custom_field"
    case `displayQrCode` = "display_qr_code"
    case `edit`
    case `editCustomField` = "edit_custom_field"
    case `excludeItemFromPasswordHealth` = "exclude_item_from_password_health"
  }
}
