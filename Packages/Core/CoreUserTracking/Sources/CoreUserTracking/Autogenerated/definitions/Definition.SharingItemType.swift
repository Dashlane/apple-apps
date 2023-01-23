import Foundation

extension Definition {

public enum `SharingItemType`: String, Encodable {
case `credential`
case `secureNote` = "secure_note"
}
}