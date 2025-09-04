import Foundation

extension AppAPIClient.DarkwebmonitoringQA {
  public struct GetSubscriptionTokens: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring-qa/GetSubscriptionTokens"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getSubscriptionTokens: GetSubscriptionTokens {
    GetSubscriptionTokens(api: api)
  }
}

extension AppAPIClient.DarkwebmonitoringQA.GetSubscriptionTokens {
  public typealias Body = Empty?
}

extension AppAPIClient.DarkwebmonitoringQA.GetSubscriptionTokens {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case tokens = "tokens"
    }

    public struct TokensElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case email = "email"
        case token = "token"
      }

      public let email: String
      public let token: String

      public init(email: String, token: String) {
        self.email = email
        self.token = token
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(token, forKey: .token)
      }
    }

    public let tokens: [TokensElement]

    public init(tokens: [TokensElement]) {
      self.tokens = tokens
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(tokens, forKey: .tokens)
    }
  }
}
