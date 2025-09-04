import Foundation

extension Definition {

  public enum `ChangeLoginEmailFlowStep`: String, Encodable, Sendable {
    case `cancelEmailChange` = "cancel_email_change"
    case `error`
    case `resendVerificationCode` = "resend_verification_code"
    case `startEmailChange` = "start_email_change"
    case `startEmailChangeBulk` = "start_email_change_bulk"
    case `submitEmailChange` = "submit_email_change"
    case `successfulEmailChange` = "successful_email_change"
    case `verifyToken` = "verify_token"
  }
}
