import Foundation

public struct AuthenticationMethodsVerifications: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case type = "type"
    case challenges = "challenges"
    case ssoInfo = "ssoInfo"
  }

  public let type: AuthenticationMethodsType
  public let challenges: [AuthenticationMethodsChallenges]?
  public let ssoInfo: AuthenticationSsoInfo?

  public init(
    type: AuthenticationMethodsType, challenges: [AuthenticationMethodsChallenges]? = nil,
    ssoInfo: AuthenticationSsoInfo? = nil
  ) {
    self.type = type
    self.challenges = challenges
    self.ssoInfo = ssoInfo
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    try container.encodeIfPresent(challenges, forKey: .challenges)
    try container.encodeIfPresent(ssoInfo, forKey: .ssoInfo)
  }
}
