import Foundation

extension UserDeviceAPIClient.Icons {
  public struct GetIcons: APIRequest {
    public static let endpoint: Endpoint = "/icons/GetIcons"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(hashes: [String], timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(hashes: hashes)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getIcons: GetIcons {
    GetIcons(api: api)
  }
}

extension UserDeviceAPIClient.Icons.GetIcons {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case hashes = "hashes"
    }

    public let hashes: [String]

    public init(hashes: [String]) {
      self.hashes = hashes
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(hashes, forKey: .hashes)
    }
  }
}

extension UserDeviceAPIClient.Icons.GetIcons {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case icons = "icons"
    }

    public struct IconsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case hash = "hash"
        case validity = "validity"
        case url = "url"
      }

      public enum Validity: String, Sendable, Equatable, CaseIterable, Codable {
        case expired = "expired"
        case invalid = "invalid"
        case valid = "valid"
        case pending = "pending"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let hash: String
      public let validity: Validity
      public let url: String?

      public init(hash: String, validity: Validity, url: String? = nil) {
        self.hash = hash
        self.validity = validity
        self.url = url
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hash, forKey: .hash)
        try container.encode(validity, forKey: .validity)
        try container.encodeIfPresent(url, forKey: .url)
      }
    }

    public let icons: [IconsElement]

    public init(icons: [IconsElement]) {
      self.icons = icons
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(icons, forKey: .icons)
    }
  }
}
