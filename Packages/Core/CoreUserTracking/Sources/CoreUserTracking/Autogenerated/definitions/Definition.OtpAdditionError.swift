import Foundation

extension Definition {

public enum `OtpAdditionError`: String, Encodable {
case `missingLogin` = "missing_login"
case `multipleCredentials` = "multiple_credentials"
case `noSecret` = "no_secret"
case `nonOtpQrCode` = "non_otp_qr_code"
case `nonOtpTextCode` = "non_otp_text_code"
case `unknownError` = "unknown_error"
}
}