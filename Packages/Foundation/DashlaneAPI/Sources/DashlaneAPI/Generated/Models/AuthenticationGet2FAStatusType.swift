import Foundation

public enum AuthenticationGet2FAStatusType: String, Codable, Equatable, CaseIterable {
    case emailToken = "email_token"
    case totpDeviceRegistration = "totp_device_registration"
    case totpLogin = "totp_login"
    case sso = "sso"
}
