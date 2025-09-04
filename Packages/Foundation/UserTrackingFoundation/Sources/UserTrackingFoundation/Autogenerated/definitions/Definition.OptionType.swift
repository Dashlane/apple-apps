import Foundation

extension Definition {

  public enum `OptionType`: String, Encodable, Sendable {
    case `login`
    case `secret`
    case `secureNote` = "secure_note"
    case `user`
    case `userGroup` = "user_group"
  }
}
