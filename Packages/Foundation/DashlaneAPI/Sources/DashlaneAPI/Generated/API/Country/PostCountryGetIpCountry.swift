import Foundation

extension AppAPIClient.Country {
  public struct GetIpCountry: APIRequest {
    public static let endpoint: Endpoint = "/country/GetIpCountry"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getIpCountry: GetIpCountry {
    GetIpCountry(api: api)
  }
}

extension AppAPIClient.Country.GetIpCountry {
  public typealias Body = Empty?
}

extension AppAPIClient.Country.GetIpCountry {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case country = "country"
      case isEu = "isEu"
      case isUS = "isUS"
    }

    public let country: String
    public let isEu: Bool
    public let isUS: Bool

    public init(country: String, isEu: Bool, isUS: Bool) {
      self.country = country
      self.isEu = isEu
      self.isUS = isUS
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(country, forKey: .country)
      try container.encode(isEu, forKey: .isEu)
      try container.encode(isUS, forKey: .isUS)
    }
  }
}
