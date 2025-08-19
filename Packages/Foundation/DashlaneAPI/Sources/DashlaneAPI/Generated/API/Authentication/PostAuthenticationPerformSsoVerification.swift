import Foundation

extension AppAPIClient.Authentication {
  public struct PerformSsoVerification: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authentication/PerformSsoVerification"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(login: String, ssoToken: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(login: login, ssoToken: ssoToken)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var performSsoVerification: PerformSsoVerification {
    PerformSsoVerification(api: api)
  }
}

extension AppAPIClient.Authentication.PerformSsoVerification {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case ssoToken = "ssoToken"
    }

    public let login: String
    public let ssoToken: String

    public init(login: String, ssoToken: String) {
      self.login = login
      self.ssoToken = ssoToken
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(ssoToken, forKey: .ssoToken)
    }
  }
}

extension AppAPIClient.Authentication.PerformSsoVerification {
  public typealias Response = AuthenticationPerformVerificationResponse
}
