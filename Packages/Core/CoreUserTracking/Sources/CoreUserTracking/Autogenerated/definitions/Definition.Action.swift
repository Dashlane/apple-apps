import Foundation

extension Definition {

  public enum `Action`: String, Encodable, Sendable {
    case `add`
    case `addCustomField` = "add_custom_field"
    case `delete`
    case `deleteCustomField` = "delete_custom_field"
    case `edit`
    case `editCustomField` = "edit_custom_field"
  }
}
