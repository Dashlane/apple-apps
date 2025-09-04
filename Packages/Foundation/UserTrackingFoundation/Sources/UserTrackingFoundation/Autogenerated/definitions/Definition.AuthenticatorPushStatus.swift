import Foundation

extension Definition {

  public enum `AuthenticatorPushStatus`: String, Encodable, Sendable {
    case `accepted`
    case `received`
    case `rejected`
  }
}
