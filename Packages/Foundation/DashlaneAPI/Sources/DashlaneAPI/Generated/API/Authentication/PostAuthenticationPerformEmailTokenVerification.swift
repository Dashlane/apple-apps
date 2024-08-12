import Foundation

extension AppAPIClient.Authentication {
  public struct PerformEmailTokenVerification: APIRequest {
    public static let endpoint: Endpoint = "/authentication/PerformEmailTokenVerification"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, token: String, intent: AuthenticationPerformVerificationIntent? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(login: login, token: token, intent: intent)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var performEmailTokenVerification: PerformEmailTokenVerification {
    PerformEmailTokenVerification(api: api)
  }
}

extension AppAPIClient.Authentication.PerformEmailTokenVerification {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case token = "token"
      case intent = "intent"
    }

    public let login: String
    public let token: String
    public let intent: AuthenticationPerformVerificationIntent?

    public init(
      login: String, token: String, intent: AuthenticationPerformVerificationIntent? = nil
    ) {
      self.login = login
      self.token = token
      self.intent = intent
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(token, forKey: .token)
      try container.encodeIfPresent(intent, forKey: .intent)
    }
  }
}

extension AppAPIClient.Authentication.PerformEmailTokenVerification {
  public typealias Response = AuthenticationPerformVerificationResponse
}
