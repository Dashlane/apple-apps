import Foundation

public struct AuthenticationMethodsLoginProfiles: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case login = "login"
    case deviceAccessKey = "deviceAccessKey"
  }

  public let login: String
  public let deviceAccessKey: String

  public init(login: String, deviceAccessKey: String) {
    self.login = login
    self.deviceAccessKey = deviceAccessKey
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(login, forKey: .login)
    try container.encode(deviceAccessKey, forKey: .deviceAccessKey)
  }
}
