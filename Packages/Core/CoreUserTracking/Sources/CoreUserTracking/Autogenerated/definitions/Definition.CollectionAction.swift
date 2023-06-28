import Foundation

extension Definition {

public enum `CollectionAction`: String, Encodable {
case `add`
case `addCredential` = "add_credential"
case `delete`
case `deleteCredential` = "delete_credential"
case `edit`
}
}