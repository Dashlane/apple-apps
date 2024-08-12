import Foundation

extension AppAPIClient.Teams {
  public struct ConfirmFreeTrial: APIRequest {
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
  public struct Body: Codable, Equatable, Sendable {
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
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case isUserCreated = "isUserCreated"
      case token = "token"
    }

    public let isUserCreated: Bool
    public let token: String?

    public init(isUserCreated: Bool, token: String? = nil) {
      self.isUserCreated = isUserCreated
      self.token = token
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(isUserCreated, forKey: .isUserCreated)
      try container.encodeIfPresent(token, forKey: .token)
    }
  }
}
