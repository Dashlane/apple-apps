import Foundation

extension Definition {

  public enum `NudgeType`: String, Encodable, Sendable {
    case `adoption`
    case `compromisedPasswords` = "compromised_passwords"
    case `notApplicable` = "not_applicable"
    case `passkey`
    case `phishing`
    case `reusedPasswords` = "reused_passwords"
    case `weakPasswords` = "weak_passwords"
  }
}
