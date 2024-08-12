import Foundation

extension AppAPIClient.Authentication {
  public struct PerformDashlaneAuthenticatorVerification: APIRequest {
    public static let endpoint: Endpoint =
      "/authentication/PerformDashlaneAuthenticatorVerification"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, deviceName: String? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(login: login, deviceName: deviceName)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var performDashlaneAuthenticatorVerification: PerformDashlaneAuthenticatorVerification {
    PerformDashlaneAuthenticatorVerification(api: api)
  }
}

extension AppAPIClient.Authentication.PerformDashlaneAuthenticatorVerification {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case deviceName = "deviceName"
    }

    public let login: String
    public let deviceName: String?

    public init(login: String, deviceName: String? = nil) {
      self.login = login
      self.deviceName = deviceName
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encodeIfPresent(deviceName, forKey: .deviceName)
    }
  }
}

extension AppAPIClient.Authentication.PerformDashlaneAuthenticatorVerification {
  public typealias Response = AuthenticationPerformVerificationResponse
}
