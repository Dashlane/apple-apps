import Foundation

extension Definition {

  public enum `ChangeMasterPasswordError`: String, Encodable, Sendable {
    case `cipherError` = "cipher_error"
    case `confirmationError` = "confirmation_error"
    case `decipherError` = "decipher_error"
    case `downloadError` = "download_error"
    case `loginError` = "login_error"
    case `passwordsDontMatch` = "passwords_dont_match"
    case `samePasswordError` = "same_password_error"
    case `syncFailedError` = "sync_failed_error"
    case `unknownError` = "unknown_error"
    case `uploadError` = "upload_error"
    case `weakPasswordError` = "weak_password_error"
    case `wrongPasswordError` = "wrong_password_error"
  }
}
