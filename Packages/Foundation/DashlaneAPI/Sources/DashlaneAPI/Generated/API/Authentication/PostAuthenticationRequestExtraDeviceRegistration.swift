import Foundation

extension UserDeviceAPIClient.Authentication {
  public struct RequestExtraDeviceRegistration: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authentication/RequestExtraDeviceRegistration"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(tokenType: Body.TokenType, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(tokenType: tokenType)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestExtraDeviceRegistration: RequestExtraDeviceRegistration {
    RequestExtraDeviceRegistration(api: api)
  }
}

extension UserDeviceAPIClient.Authentication.RequestExtraDeviceRegistration {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case tokenType = "tokenType"
    }

    public enum TokenType: String, Sendable, Hashable, Codable, CaseIterable {
      case shortLived = "shortLived"
      case googleAccountNewDevice = "googleAccountNewDevice"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let tokenType: TokenType

    public init(tokenType: TokenType) {
      self.tokenType = tokenType
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(tokenType, forKey: .tokenType)
    }
  }
}

extension UserDeviceAPIClient.Authentication.RequestExtraDeviceRegistration {
  public struct Response: Codable, Hashable, Sendable {
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
