import Foundation

extension AppAPIClient.Authentication {
  public struct Get2FAStatusUnauthenticated: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authentication/Get2FAStatusUnauthenticated"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response
    {
      let body = Body(login: login)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var get2FAStatusUnauthenticated: Get2FAStatusUnauthenticated {
    Get2FAStatusUnauthenticated(api: api)
  }
}

extension AppAPIClient.Authentication.Get2FAStatusUnauthenticated {
  public typealias Body = AuthenticationBody
}

extension AppAPIClient.Authentication.Get2FAStatusUnauthenticated {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case type = "type"
      case isDuoEnabled = "isDuoEnabled"
      case hasDashlaneAuthenticator = "hasDashlaneAuthenticator"
      case ssoInfo = "ssoInfo"
    }

    public let type: Authentication2FAStatusType
    public let isDuoEnabled: Bool
    public let hasDashlaneAuthenticator: Bool
    public let ssoInfo: AuthenticationSsoInfo?

    public init(
      type: Authentication2FAStatusType, isDuoEnabled: Bool, hasDashlaneAuthenticator: Bool,
      ssoInfo: AuthenticationSsoInfo? = nil
    ) {
      self.type = type
      self.isDuoEnabled = isDuoEnabled
      self.hasDashlaneAuthenticator = hasDashlaneAuthenticator
      self.ssoInfo = ssoInfo
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      try container.encode(isDuoEnabled, forKey: .isDuoEnabled)
      try container.encode(hasDashlaneAuthenticator, forKey: .hasDashlaneAuthenticator)
      try container.encodeIfPresent(ssoInfo, forKey: .ssoInfo)
    }
  }
}
