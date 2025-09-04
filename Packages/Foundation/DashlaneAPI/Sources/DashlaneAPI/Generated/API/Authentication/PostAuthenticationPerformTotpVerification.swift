import Foundation

extension AppAPIClient.Authentication {
  public struct PerformTotpVerification: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authentication/PerformTotpVerification"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, otp: String, activationFlow: Bool? = nil,
      intent: AuthenticationPerformVerificationIntent? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(login: login, otp: otp, activationFlow: activationFlow, intent: intent)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var performTotpVerification: PerformTotpVerification {
    PerformTotpVerification(api: api)
  }
}

extension AppAPIClient.Authentication.PerformTotpVerification {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case otp = "otp"
      case activationFlow = "activationFlow"
      case intent = "intent"
    }

    public let login: String
    public let otp: String
    public let activationFlow: Bool?
    public let intent: AuthenticationPerformVerificationIntent?

    public init(
      login: String, otp: String, activationFlow: Bool? = nil,
      intent: AuthenticationPerformVerificationIntent? = nil
    ) {
      self.login = login
      self.otp = otp
      self.activationFlow = activationFlow
      self.intent = intent
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(otp, forKey: .otp)
      try container.encodeIfPresent(activationFlow, forKey: .activationFlow)
      try container.encodeIfPresent(intent, forKey: .intent)
    }
  }
}

extension AppAPIClient.Authentication.PerformTotpVerification {
  public typealias Response = AuthenticationPerformVerificationResponse
}
