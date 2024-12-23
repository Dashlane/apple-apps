import Foundation

extension Definition {

  public enum `AccountCreationStatus`: String, Encodable, Sendable {
    case `errorAccountAlreadyExists` = "error_account_already_exists"
    case `errorNotValidEmail` = "error_not_valid_email"
    case `success`
  }
}
