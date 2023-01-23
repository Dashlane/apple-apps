import Foundation

extension Definition {

public enum `TwoFactorAuthenticationError`: String, Encodable {
case `unknownError` = "unknown_error"
case `userOfflineError` = "user_offline_error"
case `wrongBackupCodeError` = "wrong_backup_code_error"
case `wrongCodeError` = "wrong_code_error"
case `wrongPhoneFormatError` = "wrong_phone_format_error"
}
}