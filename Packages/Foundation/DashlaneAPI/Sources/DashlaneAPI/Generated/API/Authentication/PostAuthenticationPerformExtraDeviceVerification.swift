import Foundation

extension AppAPIClient.Authentication {
  public struct PerformExtraDeviceVerification: APIRequest {
    public static let endpoint: Endpoint = "/authentication/PerformExtraDeviceVerification"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(login: String, token: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(login: login, token: token)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var performExtraDeviceVerification: PerformExtraDeviceVerification {
    PerformExtraDeviceVerification(api: api)
  }
}

extension AppAPIClient.Authentication.PerformExtraDeviceVerification {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case token = "token"
    }

    public let login: String
    public let token: String

    public init(login: String, token: String) {
      self.login = login
      self.token = token
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(token, forKey: .token)
    }
  }
}

extension AppAPIClient.Authentication.PerformExtraDeviceVerification {
  public typealias Response = AuthenticationPerformVerificationResponse
}
