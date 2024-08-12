import Foundation

extension Definition {

  public enum `SharingItemType`: String, Encodable, Sendable {
    case `credential`
    case `secret`
    case `secureNote` = "secure_note"
  }
}
