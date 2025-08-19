import Foundation

extension AppAPIClient.Darkwebmonitoring {
  public struct ConfirmRegistration: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring/ConfirmRegistration"

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
  public var confirmRegistration: ConfirmRegistration {
    ConfirmRegistration(api: api)
  }
}

extension AppAPIClient.Darkwebmonitoring.ConfirmRegistration {
  public struct Body: Codable, Hashable, Sendable {
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

extension AppAPIClient.Darkwebmonitoring.ConfirmRegistration {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case email = "email"
      case requestedBy = "requestedBy"
    }

    public let email: String
    public let requestedBy: String

    public init(email: String, requestedBy: String) {
      self.email = email
      self.requestedBy = requestedBy
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(email, forKey: .email)
      try container.encode(requestedBy, forKey: .requestedBy)
    }
  }
}
