import Foundation

extension UserDeviceAPIClient.Vpn {
  public struct GetCredentials: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/vpn/GetCredentials"

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
  public var getCredentials: GetCredentials {
    GetCredentials(api: api)
  }
}

extension UserDeviceAPIClient.Vpn.GetCredentials {
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

extension UserDeviceAPIClient.Vpn.GetCredentials {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case password = "password"
    }

    public let password: String

    public init(password: String) {
      self.password = password
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(password, forKey: .password)
    }
  }
}
