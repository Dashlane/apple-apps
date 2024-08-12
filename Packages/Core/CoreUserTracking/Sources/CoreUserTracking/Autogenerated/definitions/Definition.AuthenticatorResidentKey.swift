import Foundation

extension Definition {

  public enum `AuthenticatorResidentKey`: String, Encodable, Sendable {
    case `discouraged`
    case `preferred`
    case `required`
  }
}
