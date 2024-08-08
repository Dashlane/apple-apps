import Foundation

public struct AuthenticationMethodsChallenges: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case challenge = "challenge"
    case version = "version"
    case appId = "appId"
    case keyHandle = "keyHandle"
  }

  public let challenge: String
  public let version: String
  public let appId: String
  public let keyHandle: String

  public init(challenge: String, version: String, appId: String, keyHandle: String) {
    self.challenge = challenge
    self.version = version
    self.appId = appId
    self.keyHandle = keyHandle
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(challenge, forKey: .challenge)
    try container.encode(version, forKey: .version)
    try container.encode(appId, forKey: .appId)
    try container.encode(keyHandle, forKey: .keyHandle)
  }
}
