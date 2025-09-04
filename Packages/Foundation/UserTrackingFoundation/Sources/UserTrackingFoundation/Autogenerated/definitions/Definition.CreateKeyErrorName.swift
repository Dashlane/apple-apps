import Foundation

extension Definition {

  public enum `CreateKeyErrorName`: String, Encodable, Sendable {
    case `unknown`
    case `wrongConfirmationKey` = "wrong_confirmation_key"
  }
}
