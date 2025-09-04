import Foundation

extension Definition {

  public enum `ChangeLoginError`: String, Encodable, Sendable {
    case `emailInPendingRequest` = "email_in_pending_request"
    case `existingEmail` = "existing_email"
    case `generic`
    case `invalidDomain` = "invalid_domain"
    case `invalidEmail` = "invalid_email"
    case `sameEmail` = "same_email"
    case `wrongToken` = "wrong_token"
  }
}
