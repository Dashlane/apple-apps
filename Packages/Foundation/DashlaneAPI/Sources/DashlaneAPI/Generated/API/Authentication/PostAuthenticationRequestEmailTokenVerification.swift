import Foundation

extension AppAPIClient.Authentication {
  public struct RequestEmailTokenVerification: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authentication/RequestEmailTokenVerification"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      login: String, pushNotificationId: String? = nil, u2fSecret: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(login: login, pushNotificationId: pushNotificationId, u2fSecret: u2fSecret)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestEmailTokenVerification: RequestEmailTokenVerification {
    RequestEmailTokenVerification(api: api)
  }
}

extension AppAPIClient.Authentication.RequestEmailTokenVerification {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case pushNotificationId = "pushNotificationId"
      case u2fSecret = "u2fSecret"
    }

    public let login: String
    public let pushNotificationId: String?
    public let u2fSecret: String?

    public init(login: String, pushNotificationId: String? = nil, u2fSecret: String? = nil) {
      self.login = login
      self.pushNotificationId = pushNotificationId
      self.u2fSecret = u2fSecret
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encodeIfPresent(pushNotificationId, forKey: .pushNotificationId)
      try container.encodeIfPresent(u2fSecret, forKey: .u2fSecret)
    }
  }
}

extension AppAPIClient.Authentication.RequestEmailTokenVerification {
  public typealias Response = Empty?
}
