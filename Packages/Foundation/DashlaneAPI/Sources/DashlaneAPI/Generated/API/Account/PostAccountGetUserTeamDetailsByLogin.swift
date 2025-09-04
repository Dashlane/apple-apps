import Foundation

extension AppAPIClient.Account {
  public struct GetUserTeamDetailsByLogin: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/account/GetUserTeamDetailsByLogin"

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
  public var getUserTeamDetailsByLogin: GetUserTeamDetailsByLogin {
    GetUserTeamDetailsByLogin(api: api)
  }
}

extension AppAPIClient.Account.GetUserTeamDetailsByLogin {
  public struct Body: Codable, Hashable, Sendable {
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
}

extension AppAPIClient.Account.GetUserTeamDetailsByLogin {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case teamUuid = "teamUuid"
      case isSsoEnabled = "isSsoEnabled"
      case ssoIsNitroProvider = "ssoIsNitroProvider"
    }

    public let teamUuid: String?
    public let isSsoEnabled: Bool
    public let ssoIsNitroProvider: Bool?

    public init(teamUuid: String?, isSsoEnabled: Bool, ssoIsNitroProvider: Bool?) {
      self.teamUuid = teamUuid
      self.isSsoEnabled = isSsoEnabled
      self.ssoIsNitroProvider = ssoIsNitroProvider
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(teamUuid, forKey: .teamUuid)
      try container.encode(isSsoEnabled, forKey: .isSsoEnabled)
      try container.encode(ssoIsNitroProvider, forKey: .ssoIsNitroProvider)
    }
  }
}
