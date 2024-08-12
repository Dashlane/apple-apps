import Foundation

extension AppAPIClient.AuthenticationQA {
  public struct GetDeviceRegistrationTokenForTestLogin: APIRequest {
    public static let endpoint: Endpoint =
      "/authentication-qa/GetDeviceRegistrationTokenForTestLogin"

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
  public var getDeviceRegistrationTokenForTestLogin: GetDeviceRegistrationTokenForTestLogin {
    GetDeviceRegistrationTokenForTestLogin(api: api)
  }
}

extension AppAPIClient.AuthenticationQA.GetDeviceRegistrationTokenForTestLogin {
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

extension AppAPIClient.AuthenticationQA.GetDeviceRegistrationTokenForTestLogin {
  public struct Response: Codable, Equatable, Sendable {
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
