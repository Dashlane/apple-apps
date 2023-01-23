import Foundation
import DashTypes

public enum AccountError: String, Error {
    case invalidEmail
    case alreadyExists = "account_already_exists"
    case userNotFound = "user_not_found"
    case verificationtimeOut = "verification_timeout"
    case verificationDenied = "verification_failed"
    case verificationRequiresRequest = "verification_requires_request" 
    case invalidOtpAlreadyUsed = "invalid_otp_already_used" 
    case invalidOtpBlocked = "invalid_otp_blocked" 
    case tooManyAttempts = "verification_failed_too_many_times"
    case rateLimitExceeded = "rate_limit_exceeded"
    case accountBlocked = "account_blocked_contact_support"
    case invalidInput = "invalid_input"
    case deviceDeactivated = "device_deactivated"
    case ssoBlocked = "SSO_BLOCKED" 
    case ssoMigrationNotSupported = "CLIENT_VERSION_DOES_NOT_SUPPORT_SSO_MIGRATION"
    case invalidRecoveryPhoneNumber = "phone_validation_failed"
    case expiredVersion = "expired_version"
    case malformed = "request_malformed" 
    case unknown
}

extension APIError {
    var accountError: AccountError {
        return AccountError(rawValue: code) ?? .unknown
    }
}
