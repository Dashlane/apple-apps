import Foundation

extension UserDeviceAPIClient.Breaches {
  public struct GetBreach: APIRequest {
    public static let endpoint: Endpoint = "/breaches/GetBreach"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(revision: Int, timeout: TimeInterval? = nil) async throws -> Response
    {
      let body = Body(revision: revision)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getBreach: GetBreach {
    GetBreach(api: api)
  }
}

extension UserDeviceAPIClient.Breaches.GetBreach {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
    }

    public let revision: Int

    public init(revision: Int) {
      self.revision = revision
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
    }
  }
}

extension UserDeviceAPIClient.Breaches.GetBreach {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case latestBreaches = "latestBreaches"
      case filesToDownload = "filesToDownload"
    }

    public struct LatestBreachesElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case announcedDate = "announcedDate"
        case breachCreationDate = "breachCreationDate"
        case breachModelVersion = "breachModelVersion"
        case criticality = "criticality"
        case description = "description"
        case domains = "domains"
        case eventDate = "eventDate"
        case id = "id"
        case lastModificationRevision = "lastModificationRevision"
        case leakedData = "leakedData"
        case name = "name"
        case relatedLinks = "relatedLinks"
        case restrictedArea = "restrictedArea"
        case sensitiveDomain = "sensitiveDomain"
        case status = "status"
        case template = "template"
      }

      public struct Description: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case en = "en"
        }

        public let en: String?

        public init(en: String? = nil) {
          self.en = en
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(en, forKey: .en)
        }
      }

      public let announcedDate: DateDay?
      public let breachCreationDate: Int?
      public let breachModelVersion: Int?
      public let criticality: Int?
      public let description: Description?
      public let domains: [String]?
      public let eventDate: String?
      public let id: String?
      public let lastModificationRevision: Int?
      public let leakedData: [String]?
      public let name: String?
      public let relatedLinks: [URL]?
      public let restrictedArea: [String]?
      public let sensitiveDomain: Bool?
      public let status: BreachesStatus?
      public let template: String?

      public init(
        announcedDate: DateDay? = nil, breachCreationDate: Int? = nil,
        breachModelVersion: Int? = nil, criticality: Int? = nil, description: Description? = nil,
        domains: [String]? = nil, eventDate: String? = nil, id: String? = nil,
        lastModificationRevision: Int? = nil, leakedData: [String]? = nil, name: String? = nil,
        relatedLinks: [URL]? = nil, restrictedArea: [String]? = nil, sensitiveDomain: Bool? = nil,
        status: BreachesStatus? = nil, template: String? = nil
      ) {
        self.announcedDate = announcedDate
        self.breachCreationDate = breachCreationDate
        self.breachModelVersion = breachModelVersion
        self.criticality = criticality
        self.description = description
        self.domains = domains
        self.eventDate = eventDate
        self.id = id
        self.lastModificationRevision = lastModificationRevision
        self.leakedData = leakedData
        self.name = name
        self.relatedLinks = relatedLinks
        self.restrictedArea = restrictedArea
        self.sensitiveDomain = sensitiveDomain
        self.status = status
        self.template = template
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(announcedDate, forKey: .announcedDate)
        try container.encodeIfPresent(breachCreationDate, forKey: .breachCreationDate)
        try container.encodeIfPresent(breachModelVersion, forKey: .breachModelVersion)
        try container.encodeIfPresent(criticality, forKey: .criticality)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(domains, forKey: .domains)
        try container.encodeIfPresent(eventDate, forKey: .eventDate)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(lastModificationRevision, forKey: .lastModificationRevision)
        try container.encodeIfPresent(leakedData, forKey: .leakedData)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(relatedLinks, forKey: .relatedLinks)
        try container.encodeIfPresent(restrictedArea, forKey: .restrictedArea)
        try container.encodeIfPresent(sensitiveDomain, forKey: .sensitiveDomain)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(template, forKey: .template)
      }
    }

    public let revision: Int
    public let latestBreaches: [LatestBreachesElement]
    public let filesToDownload: [String]?

    public init(
      revision: Int, latestBreaches: [LatestBreachesElement], filesToDownload: [String]? = nil
    ) {
      self.revision = revision
      self.latestBreaches = latestBreaches
      self.filesToDownload = filesToDownload
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(latestBreaches, forKey: .latestBreaches)
      try container.encodeIfPresent(filesToDownload, forKey: .filesToDownload)
    }
  }
}
