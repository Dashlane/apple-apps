import Foundation

extension AppAPIClient.Accountrecovery {
  public struct GetStatus: APIRequest {
    public static let endpoint: Endpoint = "/accountrecovery/GetStatus"

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
  public var getStatus: GetStatus {
    GetStatus(api: api)
  }
}

extension AppAPIClient.Accountrecovery.GetStatus {
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

extension AppAPIClient.Accountrecovery.GetStatus {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case enabled = "enabled"
    }

    public let enabled: Bool

    public init(enabled: Bool) {
      self.enabled = enabled
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(enabled, forKey: .enabled)
    }
  }
}
