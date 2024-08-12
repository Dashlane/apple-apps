import Foundation

extension UserDeviceAPIClient.Authentication {
  public struct RequestTOTPActivation: APIRequest {
    public static let endpoint: Endpoint = "/authentication/RequestTOTPActivation"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(phoneNumber: String, country: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(phoneNumber: phoneNumber, country: country)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestTOTPActivation: RequestTOTPActivation {
    RequestTOTPActivation(api: api)
  }
}

extension UserDeviceAPIClient.Authentication.RequestTOTPActivation {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case phoneNumber = "phoneNumber"
      case country = "country"
    }

    public let phoneNumber: String
    public let country: String

    public init(phoneNumber: String, country: String) {
      self.phoneNumber = phoneNumber
      self.country = country
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(phoneNumber, forKey: .phoneNumber)
      try container.encode(country, forKey: .country)
    }
  }
}

extension UserDeviceAPIClient.Authentication.RequestTOTPActivation {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case seed = "seed"
      case serverKey = "serverKey"
      case uri = "uri"
      case recoveryKeys = "recoveryKeys"
    }

    public let seed: String
    public let serverKey: String
    public let uri: String
    public let recoveryKeys: [String]

    public init(seed: String, serverKey: String, uri: String, recoveryKeys: [String]) {
      self.seed = seed
      self.serverKey = serverKey
      self.uri = uri
      self.recoveryKeys = recoveryKeys
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(seed, forKey: .seed)
      try container.encode(serverKey, forKey: .serverKey)
      try container.encode(uri, forKey: .uri)
      try container.encode(recoveryKeys, forKey: .recoveryKeys)
    }
  }
}
