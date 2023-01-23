import Foundation

extension Definition {

public enum `Status`: String, Encodable {
case `errorInvalidSso` = "error_invalid_sso"
case `errorUnknown` = "error_unknown"
case `errorWrongBackupCode` = "error_wrong_backup_code"
case `errorWrongBiometric` = "error_wrong_biometric"
case `errorWrongEmail` = "error_wrong_email"
case `errorWrongOtp` = "error_wrong_otp"
case `errorWrongPassword` = "error_wrong_password"
case `errorWrongPin` = "error_wrong_pin"
case `success`
}
}