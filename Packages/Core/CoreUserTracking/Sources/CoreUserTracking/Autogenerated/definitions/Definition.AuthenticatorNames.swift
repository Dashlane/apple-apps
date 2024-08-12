import Foundation

extension Definition {

  public enum `AuthenticatorNames`: String, Encodable, Sendable {
    case `authy`
    case `duo`
    case `google`
    case `lastpass`
    case `microsoft`
  }
}
