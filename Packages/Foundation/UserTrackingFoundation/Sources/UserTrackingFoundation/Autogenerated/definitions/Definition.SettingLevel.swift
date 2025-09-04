import Foundation

extension Definition {

  public enum `SettingLevel`: String, Encodable, Sendable {
    case `credentials`
    case `global`
    case `ids`
    case `payments`
    case `secureNotes` = "secure_notes"
  }
}
