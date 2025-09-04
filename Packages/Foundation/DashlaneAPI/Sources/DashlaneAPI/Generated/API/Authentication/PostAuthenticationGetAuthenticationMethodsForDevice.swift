import Foundation

extension AppAPIClient.Authentication {
  public struct GetAuthenticationMethodsForDevice: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authentication/GetAuthenticationMethodsForDevice"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, methods: [AuthenticationMethods], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(login: login, methods: methods)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAuthenticationMethodsForDevice: GetAuthenticationMethodsForDevice {
    GetAuthenticationMethodsForDevice(api: api)
  }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForDevice {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case methods = "methods"
    }

    public let login: String
    public let methods: [AuthenticationMethods]

    public init(login: String, methods: [AuthenticationMethods]) {
      self.login = login
      self.methods = methods
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(methods, forKey: .methods)
    }
  }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForDevice {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case verifications = "verifications"
      case accountType = "accountType"
    }

    public let verifications: [AuthenticationMethodsVerifications]
    public let accountType: AuthenticationMethodsAccountType

    public init(
      verifications: [AuthenticationMethodsVerifications],
      accountType: AuthenticationMethodsAccountType
    ) {
      self.verifications = verifications
      self.accountType = accountType
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(verifications, forKey: .verifications)
      try container.encode(accountType, forKey: .accountType)
    }
  }
}
