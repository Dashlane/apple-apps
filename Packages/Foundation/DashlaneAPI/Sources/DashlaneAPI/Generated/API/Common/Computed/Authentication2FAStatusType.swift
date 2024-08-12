import Foundation

public enum Authentication2FAStatusType: String, Sendable, Equatable, CaseIterable, Codable {
  case emailToken = "email_token"
  case totpDeviceRegistration = "totp_device_registration"
  case totpLogin = "totp_login"
  case sso = "sso"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
