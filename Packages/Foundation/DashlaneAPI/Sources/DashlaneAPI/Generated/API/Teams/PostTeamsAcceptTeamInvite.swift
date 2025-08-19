import Foundation

extension AppAPIClient.Teams {
  public struct AcceptTeamInvite: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/teams/AcceptTeamInvite"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(inviteToken: String, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(inviteToken: inviteToken)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var acceptTeamInvite: AcceptTeamInvite {
    AcceptTeamInvite(api: api)
  }
}

extension AppAPIClient.Teams.AcceptTeamInvite {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case inviteToken = "inviteToken"
    }

    public let inviteToken: String

    public init(inviteToken: String) {
      self.inviteToken = inviteToken
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(inviteToken, forKey: .inviteToken)
    }
  }
}

extension AppAPIClient.Teams.AcceptTeamInvite {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case isAccountCreated = "isAccountCreated"
      case teamName = "teamName"
      case login = "login"
      case ssoIsNitroProvider = "ssoIsNitroProvider"
      case ssoServiceProviderUrl = "ssoServiceProviderUrl"
      case ssoStatus = "ssoStatus"
    }

    public enum SsoStatus: String, Sendable, Hashable, Codable, CaseIterable {
      case activated = "activated"
      case pendingActivation = "pending_activation"
      case pendingDeactivation = "pending_deactivation"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let isAccountCreated: Bool
    public let teamName: String?
    public let login: String
    public let ssoIsNitroProvider: Bool?
    public let ssoServiceProviderUrl: String?
    public let ssoStatus: SsoStatus?

    public init(
      isAccountCreated: Bool, teamName: String?, login: String, ssoIsNitroProvider: Bool? = nil,
      ssoServiceProviderUrl: String? = nil, ssoStatus: SsoStatus? = nil
    ) {
      self.isAccountCreated = isAccountCreated
      self.teamName = teamName
      self.login = login
      self.ssoIsNitroProvider = ssoIsNitroProvider
      self.ssoServiceProviderUrl = ssoServiceProviderUrl
      self.ssoStatus = ssoStatus
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(isAccountCreated, forKey: .isAccountCreated)
      try container.encode(teamName, forKey: .teamName)
      try container.encode(login, forKey: .login)
      try container.encodeIfPresent(ssoIsNitroProvider, forKey: .ssoIsNitroProvider)
      try container.encodeIfPresent(ssoServiceProviderUrl, forKey: .ssoServiceProviderUrl)
      try container.encodeIfPresent(ssoStatus, forKey: .ssoStatus)
    }
  }
}
