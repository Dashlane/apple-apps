import Foundation

extension Definition {

  public enum `MatchType`: String, Encodable, Sendable {
    case `associatedApp` = "associated_app"
    case `associatedWebsite` = "associated_website"
    case `createdPassword` = "created_password"
    case `explorePasswords` = "explore_passwords"
    case `regular`
    case `remembered`
    case `userAssociatedWebsite` = "user_associated_website"
  }
}
