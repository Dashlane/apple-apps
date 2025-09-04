import Foundation

extension Definition {

  public enum `PasswordChangerFailureReason`: String, Encodable, Sendable {
    case `clientError` = "client_error"
    case `identityError` = "identity_error"
    case `loginError` = "login_error"
    case `networkError` = "network_error"
    case `recipeError` = "recipe_error"
    case `serverError` = "server_error"
    case `userCancel` = "user_cancel"
  }
}
