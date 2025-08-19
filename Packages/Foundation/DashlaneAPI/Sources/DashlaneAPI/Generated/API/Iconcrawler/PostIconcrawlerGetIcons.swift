import Foundation

extension AppAPIClient.Iconcrawler {
  public struct GetIcons: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/iconcrawler/GetIcons"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(domainsInfo: [Body.DomainsInfoElement], timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(domainsInfo: domainsInfo)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getIcons: GetIcons {
    GetIcons(api: api)
  }
}

extension AppAPIClient.Iconcrawler.GetIcons {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case domainsInfo = "domainsInfo"
    }

    public struct DomainsInfoElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case domain = "domain"
        case type = "type"
      }

      public let domain: String
      public let type: String

      public init(domain: String, type: String) {
        self.domain = domain
        self.type = type
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(domain, forKey: .domain)
        try container.encode(type, forKey: .type)
      }
    }

    public let domainsInfo: [DomainsInfoElement]

    public init(domainsInfo: [DomainsInfoElement]) {
      self.domainsInfo = domainsInfo
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(domainsInfo, forKey: .domainsInfo)
    }
  }
}

extension AppAPIClient.Iconcrawler.GetIcons {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case icons = "icons"
    }

    public struct IconsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case backgroundColor = "backgroundColor"
        case mainColor = "mainColor"
        case fallbackColor = "fallbackColor"
        case domain = "domain"
        case date = "date"
        case type = "type"
        case url = "url"
      }

      public let backgroundColor: String
      public let mainColor: String
      public let fallbackColor: String
      public let domain: String
      public let date: Int?
      public let type: String?
      public let url: String?

      public init(
        backgroundColor: String, mainColor: String, fallbackColor: String, domain: String,
        date: Int? = nil, type: String? = nil, url: String? = nil
      ) {
        self.backgroundColor = backgroundColor
        self.mainColor = mainColor
        self.fallbackColor = fallbackColor
        self.domain = domain
        self.date = date
        self.type = type
        self.url = url
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(mainColor, forKey: .mainColor)
        try container.encode(fallbackColor, forKey: .fallbackColor)
        try container.encode(domain, forKey: .domain)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(type, forKey: .type)
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
