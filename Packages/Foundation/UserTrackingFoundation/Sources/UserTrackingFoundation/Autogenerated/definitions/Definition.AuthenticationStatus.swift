import Foundation

extension Definition {

  public enum `AuthenticationStatus`: String, Encodable, Sendable {
    case `lockedOut` = "locked_out"
    case `loggedIn` = "logged_in"
    case `loggedOut` = "logged_out"
  }
}
