import Foundation

extension UserDeviceAPIClient.Darkwebmonitoring {
  public struct Unsubscribe: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring/Unsubscribe"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(key: String, timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body(key: key)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var unsubscribe: Unsubscribe {
    Unsubscribe(api: api)
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.Unsubscribe {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case key = "key"
    }

    public let key: String

    public init(key: String) {
      self.key = key
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(key, forKey: .key)
    }
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.Unsubscribe {
  public struct Response: Codable, Hashable, Sendable {
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
