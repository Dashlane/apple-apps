import Foundation

public struct TwoFactorStatusResponse: Decodable {
    public enum SecondAuthenticationFactor: String, Decodable {
                case email = "email_token"
                case totpDeviceRegistration = "totp_device_registration"
                case totpEachLogin = "totp_login"
    }
    public let type: SecondAuthenticationFactor
    public let isDuoEnabled: Bool
    public let hasU2FKeys: Bool
}
