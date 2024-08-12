import Foundation

extension Definition {

  public enum `AuthenticatorUserVerification`: String, Encodable, Sendable {
    case `discouraged`
    case `preferred`
    case `required`
  }
}
