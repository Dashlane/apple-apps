import Foundation

extension UserDeviceAPIClient.Darkwebmonitoring {
  public struct ListLeaks: APIRequest {
    public static let endpoint: Endpoint = "/darkwebmonitoring/ListLeaks"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      includeDisabled: Bool? = nil, lastUpdateDate: Int? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(includeDisabled: includeDisabled, lastUpdateDate: lastUpdateDate)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var listLeaks: ListLeaks {
    ListLeaks(api: api)
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListLeaks {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case includeDisabled = "includeDisabled"
      case lastUpdateDate = "lastUpdateDate"
    }

    @available(*, deprecated, message: "Deprecated in Spec")
    public let includeDisabled: Bool?
    public let lastUpdateDate: Int?

    public init(includeDisabled: Bool? = nil, lastUpdateDate: Int? = nil) {
      self.includeDisabled = includeDisabled
      self.lastUpdateDate = lastUpdateDate
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(includeDisabled, forKey: .includeDisabled)
      try container.encodeIfPresent(lastUpdateDate, forKey: .lastUpdateDate)
    }
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListLeaks {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case lastUpdateDate = "lastUpdateDate"
      case details = "details"
      case emails = "emails"
      case leaks = "leaks"
    }

    public struct Details: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case cipheredKey = "cipheredKey"
        case cipheredInfo = "cipheredInfo"
      }

      public let cipheredKey: String
      public let cipheredInfo: String

      public init(cipheredKey: String, cipheredInfo: String) {
        self.cipheredKey = cipheredKey
        self.cipheredInfo = cipheredInfo
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cipheredKey, forKey: .cipheredKey)
        try container.encode(cipheredInfo, forKey: .cipheredInfo)
      }
    }

    public struct LeaksElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case breachCreationDate = "breachCreationDate"
        case breachModelVersion = "breachModelVersion"
        case domains = "domains"
        case id = "id"
        case impactedEmails = "impactedEmails"
        case lastModificationRevision = "lastModificationRevision"
        case leakedData = "leakedData"
        case status = "status"
        case announcedDate = "announcedDate"
        case breachUpdateDate = "breachUpdateDate"
        case eventDate = "eventDate"
      }

      public let breachCreationDate: Int
      public let breachModelVersion: Int
      public let domains: [String]
      public let id: String
      public let impactedEmails: [String]
      public let lastModificationRevision: Int
      public let leakedData: [String]
      public let status: String
      public let announcedDate: String?
      public let breachUpdateDate: Int?
      public let eventDate: String?

      public init(
        breachCreationDate: Int, breachModelVersion: Int, domains: [String], id: String,
        impactedEmails: [String], lastModificationRevision: Int, leakedData: [String],
        status: String, announcedDate: String? = nil, breachUpdateDate: Int? = nil,
        eventDate: String? = nil
      ) {
        self.breachCreationDate = breachCreationDate
        self.breachModelVersion = breachModelVersion
        self.domains = domains
        self.id = id
        self.impactedEmails = impactedEmails
        self.lastModificationRevision = lastModificationRevision
        self.leakedData = leakedData
        self.status = status
        self.announcedDate = announcedDate
        self.breachUpdateDate = breachUpdateDate
        self.eventDate = eventDate
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(breachCreationDate, forKey: .breachCreationDate)
        try container.encode(breachModelVersion, forKey: .breachModelVersion)
        try container.encode(domains, forKey: .domains)
        try container.encode(id, forKey: .id)
        try container.encode(impactedEmails, forKey: .impactedEmails)
        try container.encode(lastModificationRevision, forKey: .lastModificationRevision)
        try container.encode(leakedData, forKey: .leakedData)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(announcedDate, forKey: .announcedDate)
        try container.encodeIfPresent(breachUpdateDate, forKey: .breachUpdateDate)
        try container.encodeIfPresent(eventDate, forKey: .eventDate)
      }
    }

    public let lastUpdateDate: Int
    public let details: Details?
    public let emails: [DarkwebmonitoringListEmails]?
    public let leaks: [LeaksElement]?

    public init(
      lastUpdateDate: Int, details: Details? = nil, emails: [DarkwebmonitoringListEmails]? = nil,
      leaks: [LeaksElement]? = nil
    ) {
      self.lastUpdateDate = lastUpdateDate
      self.details = details
      self.emails = emails
      self.leaks = leaks
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(lastUpdateDate, forKey: .lastUpdateDate)
      try container.encodeIfPresent(details, forKey: .details)
      try container.encodeIfPresent(emails, forKey: .emails)
      try container.encodeIfPresent(leaks, forKey: .leaks)
    }
  }
}
