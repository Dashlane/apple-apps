import Foundation

public struct AuthenticationMethodsVerifications: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case type = "type"
    case challenges = "challenges"
    case ssoInfo = "ssoInfo"
  }

  public struct SsoInfo: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case serviceProviderUrl = "serviceProviderUrl"
      case isNitroProvider = "isNitroProvider"
      case migration = "migration"
    }

    public let serviceProviderUrl: String
    public let isNitroProvider: Bool?
    public let migration: AuthenticationMigration?

    public init(
      serviceProviderUrl: String, isNitroProvider: Bool? = nil,
      migration: AuthenticationMigration? = nil
    ) {
      self.serviceProviderUrl = serviceProviderUrl
      self.isNitroProvider = isNitroProvider
      self.migration = migration
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(serviceProviderUrl, forKey: .serviceProviderUrl)
      try container.encodeIfPresent(isNitroProvider, forKey: .isNitroProvider)
      try container.encodeIfPresent(migration, forKey: .migration)
    }
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
