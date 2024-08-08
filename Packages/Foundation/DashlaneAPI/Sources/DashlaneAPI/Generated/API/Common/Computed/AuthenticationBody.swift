import Foundation

public struct AuthenticationBody: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case login = "login"
  }

  public let login: String

  public init(login: String) {
    self.login = login
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(login, forKey: .login)
  }
}
