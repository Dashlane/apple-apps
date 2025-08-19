import Foundation

extension AppAPIClient.Account {
  public struct GetUserIdentityByLogin: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/account/GetUserIdentityByLogin"

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
  public var getUserIdentityByLogin: GetUserIdentityByLogin {
    GetUserIdentityByLogin(api: api)
  }
}

extension AppAPIClient.Account.GetUserIdentityByLogin {
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

extension AppAPIClient.Account.GetUserIdentityByLogin {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case userId = "userId"
    }

    public let userId: Int

    public init(userId: Int) {
      self.userId = userId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(userId, forKey: .userId)
    }
  }
}
