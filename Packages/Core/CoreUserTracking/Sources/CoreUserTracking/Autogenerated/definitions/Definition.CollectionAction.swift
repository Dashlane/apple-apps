import Foundation

extension Definition {

  public enum `CollectionAction`: String, Encodable, Sendable {
    case `add`
    case `addCredential` = "add_credential"
    case `delete`
    case `deleteCredential` = "delete_credential"
    case `edit`
    case `rename`
    case `renameCredential` = "rename_credential"
  }
}
