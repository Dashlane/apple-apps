import Foundation

extension AppAPIClient.Teams {
  public struct ConfirmFreeTrial: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/teams/ConfirmFreeTrial"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(token: String, timeout: TimeInterval? = nil) async throws -> Response
    {
      let body = Body(token: token)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var confirmFreeTrial: ConfirmFreeTrial {
    ConfirmFreeTrial(api: api)
  }
}

extension AppAPIClient.Teams.ConfirmFreeTrial {
  public struct Body: Codable, Hashable, Sendable {
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
}

extension AppAPIClient.Teams.ConfirmFreeTrial {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case isUserCreated = "isUserCreated"
      case login = "login"
      case withNewFlow = "withNewFlow"
      case withSkipButton = "withSkipButton"
      case token = "token"
    }

    public let isUserCreated: Bool
    public let login: String
    public let withNewFlow: Bool
    public let withSkipButton: Bool
    public let token: String?

    public init(
      isUserCreated: Bool, login: String, withNewFlow: Bool, withSkipButton: Bool,
      token: String? = nil
    ) {
      self.isUserCreated = isUserCreated
      self.login = login
      self.withNewFlow = withNewFlow
      self.withSkipButton = withSkipButton
      self.token = token
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(isUserCreated, forKey: .isUserCreated)
      try container.encode(login, forKey: .login)
      try container.encode(withNewFlow, forKey: .withNewFlow)
      try container.encode(withSkipButton, forKey: .withSkipButton)
      try container.encodeIfPresent(token, forKey: .token)
    }
  }
}
