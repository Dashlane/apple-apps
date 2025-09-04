import Foundation

extension Definition {

  public enum `UseKeyErrorName`: String, Encodable, Sendable {
    case `unknown`
    case `wrongKeyEntered` = "wrong_key_entered"
  }
}
