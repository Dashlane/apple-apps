import Foundation

extension UserDeviceAPIClient.Darkwebmonitoring {
  public struct DeregisterEmail: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring/DeregisterEmail"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(email: String, timeout: TimeInterval? = nil) async throws -> Response
    {
      let body = Body(email: email)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deregisterEmail: DeregisterEmail {
    DeregisterEmail(api: api)
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.DeregisterEmail {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case email = "email"
    }

    public let email: String

    public init(email: String) {
      self.email = email
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(email, forKey: .email)
    }
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.DeregisterEmail {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case email = "email"
      case result = "result"
    }

    public let email: String
    public let result: String

    public init(email: String, result: String) {
      self.email = email
      self.result = result
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(email, forKey: .email)
      try container.encode(result, forKey: .result)
    }
  }
}
