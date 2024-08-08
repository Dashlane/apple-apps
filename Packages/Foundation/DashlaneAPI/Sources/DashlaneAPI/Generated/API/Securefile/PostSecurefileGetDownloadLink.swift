import Foundation

extension UserDeviceAPIClient.Securefile {
  public struct GetDownloadLink: APIRequest {
    public static let endpoint: Endpoint = "/securefile/GetDownloadLink"

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
  public var getDownloadLink: GetDownloadLink {
    GetDownloadLink(api: api)
  }
}

extension UserDeviceAPIClient.Securefile.GetDownloadLink {
  public struct Body: Codable, Equatable, Sendable {
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

extension UserDeviceAPIClient.Securefile.GetDownloadLink {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case url = "url"
    }

    public let url: String

    public init(url: String) {
      self.url = url
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(url, forKey: .url)
    }
  }
}
