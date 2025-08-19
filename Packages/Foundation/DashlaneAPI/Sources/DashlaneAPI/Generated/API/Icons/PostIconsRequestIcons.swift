import Foundation

extension UserDeviceAPIClient.Icons {
  public struct RequestIcons: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/icons/RequestIcons"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(domains: [String], timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(domains: domains)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestIcons: RequestIcons {
    RequestIcons(api: api)
  }
}

extension UserDeviceAPIClient.Icons.RequestIcons {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case domains = "domains"
    }

    public let domains: [String]

    public init(domains: [String]) {
      self.domains = domains
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(domains, forKey: .domains)
    }
  }
}

extension UserDeviceAPIClient.Icons.RequestIcons {
  public typealias Response = Empty?
}
