import Foundation

extension AppAPIClient.Breaches {
  public struct ListBreaches: APIRequest {
    public static let endpoint: Endpoint = "/breaches/ListBreaches"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      livemode: Bool, pageCount: Int, pageNumber: Int, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(livemode: livemode, pageCount: pageCount, pageNumber: pageNumber)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var listBreaches: ListBreaches {
    ListBreaches(api: api)
  }
}

extension AppAPIClient.Breaches.ListBreaches {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case livemode = "livemode"
      case pageCount = "pageCount"
      case pageNumber = "pageNumber"
    }

    public let livemode: Bool
    public let pageCount: Int
    public let pageNumber: Int

    public init(livemode: Bool, pageCount: Int, pageNumber: Int) {
      self.livemode = livemode
      self.pageCount = pageCount
      self.pageNumber = pageNumber
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(livemode, forKey: .livemode)
      try container.encode(pageCount, forKey: .pageCount)
      try container.encode(pageNumber, forKey: .pageNumber)
    }
  }
}

extension AppAPIClient.Breaches.ListBreaches {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case breaches = "breaches"
    }

    public struct BreachesElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case creationDateUnix = "creationDateUnix"
        case definition = "definition"
        case deletionDateUnix = "deletionDateUnix"
        case id = "id"
        case livemode = "livemode"
        case revision = "revision"
        case updateDateUnix = "updateDateUnix"
        case uri = "uri"
      }

      public struct Definition: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case announcedDate = "announcedDate"
          case breachModelVersion = "breachModelVersion"
          case criticality = "criticality"
          case domains = "domains"
          case eventDate = "eventDate"
          case id = "id"
          case leakedData = "leakedData"
          case name = "name"
          case sensitiveDomain = "sensitiveDomain"
          case status = "status"
          case template = "template"
          case breachCreationDate = "breachCreationDate"
          case lastModificationRevision = "lastModificationRevision"
          case relatedLinks = "relatedLinks"
        }

        public enum Status: String, Sendable, Equatable, CaseIterable, Codable {
          case legacy = "legacy"
          case live = "live"
          case staging = "staging"
          case deleted = "deleted"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let announcedDate: DateDay
        public let breachModelVersion: Int
        public let criticality: Int
        public let domains: [String]
        public let eventDate: String
        public let id: String
        public let leakedData: [String]
        public let name: String
        public let sensitiveDomain: Bool
        public let status: BreachesStatus
        public let template: String
        public let breachCreationDate: Int?
        public let lastModificationRevision: Int?
        public let relatedLinks: [URL]?

        public init(
          announcedDate: DateDay, breachModelVersion: Int, criticality: Int, domains: [String],
          eventDate: String, id: String, leakedData: [String], name: String, sensitiveDomain: Bool,
          status: BreachesStatus, template: String, breachCreationDate: Int? = nil,
          lastModificationRevision: Int? = nil, relatedLinks: [URL]? = nil
        ) {
          self.announcedDate = announcedDate
          self.breachModelVersion = breachModelVersion
          self.criticality = criticality
          self.domains = domains
          self.eventDate = eventDate
          self.id = id
          self.leakedData = leakedData
          self.name = name
          self.sensitiveDomain = sensitiveDomain
          self.status = status
          self.template = template
          self.breachCreationDate = breachCreationDate
          self.lastModificationRevision = lastModificationRevision
          self.relatedLinks = relatedLinks
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(announcedDate, forKey: .announcedDate)
          try container.encode(breachModelVersion, forKey: .breachModelVersion)
          try container.encode(criticality, forKey: .criticality)
          try container.encode(domains, forKey: .domains)
          try container.encode(eventDate, forKey: .eventDate)
          try container.encode(id, forKey: .id)
          try container.encode(leakedData, forKey: .leakedData)
          try container.encode(name, forKey: .name)
          try container.encode(sensitiveDomain, forKey: .sensitiveDomain)
          try container.encode(status, forKey: .status)
          try container.encode(template, forKey: .template)
          try container.encodeIfPresent(breachCreationDate, forKey: .breachCreationDate)
          try container.encodeIfPresent(lastModificationRevision, forKey: .lastModificationRevision)
          try container.encodeIfPresent(relatedLinks, forKey: .relatedLinks)
        }
      }

      public let creationDateUnix: Int
      public let definition: Definition
      public let deletionDateUnix: Int?
      public let id: Int
      public let livemode: Bool
      public let revision: Int
      public let updateDateUnix: Int?
      public let uri: String

      public init(
        creationDateUnix: Int, definition: Definition, deletionDateUnix: Int?, id: Int,
        livemode: Bool, revision: Int, updateDateUnix: Int?, uri: String
      ) {
        self.creationDateUnix = creationDateUnix
        self.definition = definition
        self.deletionDateUnix = deletionDateUnix
        self.id = id
        self.livemode = livemode
        self.revision = revision
        self.updateDateUnix = updateDateUnix
        self.uri = uri
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creationDateUnix, forKey: .creationDateUnix)
        try container.encode(definition, forKey: .definition)
        try container.encode(deletionDateUnix, forKey: .deletionDateUnix)
        try container.encode(id, forKey: .id)
        try container.encode(livemode, forKey: .livemode)
        try container.encode(revision, forKey: .revision)
        try container.encode(updateDateUnix, forKey: .updateDateUnix)
        try container.encode(uri, forKey: .uri)
      }
    }

    public let breaches: [BreachesElement]?

    public init(breaches: [BreachesElement]? = nil) {
      self.breaches = breaches
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(breaches, forKey: .breaches)
    }
  }
}
