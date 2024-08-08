import Foundation

extension AppAPIClient.Authentication {
  public struct GetAuthenticationMethodsForLogin: APIRequest {
    public static let endpoint: Endpoint = "/authentication/GetAuthenticationMethodsForLogin"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, deviceAccessKey: String, methods: [AuthenticationMethods],
      profiles: [AuthenticationMethodsLoginProfiles]? = nil, u2fSecret: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        login: login, deviceAccessKey: deviceAccessKey, methods: methods, profiles: profiles,
        u2fSecret: u2fSecret)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAuthenticationMethodsForLogin: GetAuthenticationMethodsForLogin {
    GetAuthenticationMethodsForLogin(api: api)
  }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForLogin {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case deviceAccessKey = "deviceAccessKey"
      case methods = "methods"
      case profiles = "profiles"
      case u2fSecret = "u2fSecret"
    }

    public let login: String
    public let deviceAccessKey: String
    public let methods: [AuthenticationMethods]
    public let profiles: [AuthenticationMethodsLoginProfiles]?
    public let u2fSecret: String?

    public init(
      login: String, deviceAccessKey: String, methods: [AuthenticationMethods],
      profiles: [AuthenticationMethodsLoginProfiles]? = nil, u2fSecret: String? = nil
    ) {
      self.login = login
      self.deviceAccessKey = deviceAccessKey
      self.methods = methods
      self.profiles = profiles
      self.u2fSecret = u2fSecret
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(deviceAccessKey, forKey: .deviceAccessKey)
      try container.encode(methods, forKey: .methods)
      try container.encodeIfPresent(profiles, forKey: .profiles)
      try container.encodeIfPresent(u2fSecret, forKey: .u2fSecret)
    }
  }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForLogin {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case verifications = "verifications"
      case accountType = "accountType"
      case profilesToDelete = "profilesToDelete"
    }

    public let verifications: [AuthenticationMethodsVerifications]
    public let accountType: AuthenticationMethodsAccountType
    public let profilesToDelete: [AuthenticationMethodsLoginProfiles]?

    public init(
      verifications: [AuthenticationMethodsVerifications],
      accountType: AuthenticationMethodsAccountType,
      profilesToDelete: [AuthenticationMethodsLoginProfiles]? = nil
    ) {
      self.verifications = verifications
      self.accountType = accountType
      self.profilesToDelete = profilesToDelete
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(verifications, forKey: .verifications)
      try container.encode(accountType, forKey: .accountType)
      try container.encodeIfPresent(profilesToDelete, forKey: .profilesToDelete)
    }
  }
}
