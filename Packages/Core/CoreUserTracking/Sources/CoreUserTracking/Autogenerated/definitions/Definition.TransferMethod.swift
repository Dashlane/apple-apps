import Foundation

extension Definition {

  public enum `TransferMethod`: String, Encodable, Sendable {
    case `accountRecoveryKey` = "account_recovery_key"
    case `notSelected` = "not_selected"
    case `qrCode` = "qr_code"
    case `securityChallenge` = "security_challenge"
  }
}
