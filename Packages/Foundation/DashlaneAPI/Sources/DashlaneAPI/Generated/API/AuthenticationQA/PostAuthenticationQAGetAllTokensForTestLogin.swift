import Foundation

extension AppAPIClient.AuthenticationQA {
  public struct GetAllTokensForTestLogin: APIRequest {
    public static let endpoint: Endpoint = "/authentication-qa/GetAllTokensForTestLogin"

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
  public var getAllTokensForTestLogin: GetAllTokensForTestLogin {
    GetAllTokensForTestLogin(api: api)
  }
}

extension AppAPIClient.AuthenticationQA.GetAllTokensForTestLogin {
  public struct Body: Codable, Equatable, Sendable {
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

extension AppAPIClient.AuthenticationQA.GetAllTokensForTestLogin {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case teamInviteTokens = "teamInviteTokens"
      case teamFreeTrialTokens = "teamFreeTrialTokens"
      case resetToken = "resetToken"
      case newDeviceToken = "newDeviceToken"
      case deleteToken = "deleteToken"
      case emailSubscriptionTokens = "emailSubscriptionTokens"
    }

    public struct TeamInviteTokensElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case teamId = "teamId"
        case token = "token"
      }

      public let teamId: Int
      public let token: String

      public init(teamId: Int, token: String) {
        self.teamId = teamId
        self.token = token
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teamId, forKey: .teamId)
        try container.encode(token, forKey: .token)
      }
    }

    public struct TeamFreeTrialTokensElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case token = "token"
      }

      public let token: String

      public init(token: String) {
        self.token = token
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
      }
    }

    public struct EmailSubscriptionTokensElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case token = "token"
        case email = "email"
      }

      public let token: String
      public let email: String

      public init(token: String, email: String) {
        self.token = token
        self.email = email
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
        try container.encode(email, forKey: .email)
      }
    }

    public let teamInviteTokens: [TeamInviteTokensElement]
    public let teamFreeTrialTokens: [TeamFreeTrialTokensElement]
    public let resetToken: String?
    public let newDeviceToken: String?
    public let deleteToken: String?
    public let emailSubscriptionTokens: [EmailSubscriptionTokensElement]

    public init(
      teamInviteTokens: [TeamInviteTokensElement],
      teamFreeTrialTokens: [TeamFreeTrialTokensElement], resetToken: String?,
      newDeviceToken: String?, deleteToken: String?,
      emailSubscriptionTokens: [EmailSubscriptionTokensElement]
    ) {
      self.teamInviteTokens = teamInviteTokens
      self.teamFreeTrialTokens = teamFreeTrialTokens
      self.resetToken = resetToken
      self.newDeviceToken = newDeviceToken
      self.deleteToken = deleteToken
      self.emailSubscriptionTokens = emailSubscriptionTokens
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(teamInviteTokens, forKey: .teamInviteTokens)
      try container.encode(teamFreeTrialTokens, forKey: .teamFreeTrialTokens)
      try container.encode(resetToken, forKey: .resetToken)
      try container.encode(newDeviceToken, forKey: .newDeviceToken)
      try container.encode(deleteToken, forKey: .deleteToken)
      try container.encode(emailSubscriptionTokens, forKey: .emailSubscriptionTokens)
    }
  }
}
