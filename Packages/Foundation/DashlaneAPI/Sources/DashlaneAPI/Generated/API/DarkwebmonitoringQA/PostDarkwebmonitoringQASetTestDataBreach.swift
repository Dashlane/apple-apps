import Foundation

extension AppAPIClient.DarkwebmonitoringQA {
  public struct SetTestDataBreach: APIRequest {
    public static let endpoint: Endpoint = "/darkwebmonitoring-qa/SetTestDataBreach"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(databreach: Body.Databreach, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(databreach: databreach)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var setTestDataBreach: SetTestDataBreach {
    SetTestDataBreach(api: api)
  }
}

extension AppAPIClient.DarkwebmonitoringQA.SetTestDataBreach {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case databreach = "databreach"
    }

    public struct Databreach: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case breachDateUnix = "breachDateUnix"
        case details = "details"
        case domain = "domain"
      }

      public let uuid: String
      public let breachDateUnix: Int
      public let details: String?
      public let domain: String?

      public init(uuid: String, breachDateUnix: Int, details: String? = nil, domain: String? = nil)
      {
        self.uuid = uuid
        self.breachDateUnix = breachDateUnix
        self.details = details
        self.domain = domain
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(breachDateUnix, forKey: .breachDateUnix)
        try container.encodeIfPresent(details, forKey: .details)
        try container.encodeIfPresent(domain, forKey: .domain)
      }
    }

    public let databreach: Databreach

    public init(databreach: Databreach) {
      self.databreach = databreach
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(databreach, forKey: .databreach)
    }
  }
}

extension AppAPIClient.DarkwebmonitoringQA.SetTestDataBreach {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case breachId = "breachId"
      case livemode = "livemode"
      case domain = "domain"
      case breachDateUnix = "breachDateUnix"
      case details = "details"
      case status = "status"
      case uri = "uri"
      case creationDateUnix = "creationDateUnix"
      case updateDateUnix = "updateDateUnix"
      case uuid = "uuid"
    }

    public enum Status: String, Sendable, Equatable, CaseIterable, Codable {
      case staging = "staging"
      case live = "live"
      case pending = "pending"
      case hidden = "hidden"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let breachId: Int
    public let livemode: Bool
    public let domain: String?
    public let breachDateUnix: Int
    public let details: String
    public let status: Status
    public let uri: String?
    public let creationDateUnix: Int
    public let updateDateUnix: Int?
    public let uuid: String?

    public init(
      breachId: Int, livemode: Bool, domain: String?, breachDateUnix: Int, details: String,
      status: Status, uri: String?, creationDateUnix: Int, updateDateUnix: Int? = nil,
      uuid: String? = nil
    ) {
      self.breachId = breachId
      self.livemode = livemode
      self.domain = domain
      self.breachDateUnix = breachDateUnix
      self.details = details
      self.status = status
      self.uri = uri
      self.creationDateUnix = creationDateUnix
      self.updateDateUnix = updateDateUnix
      self.uuid = uuid
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(breachId, forKey: .breachId)
      try container.encode(livemode, forKey: .livemode)
      try container.encode(domain, forKey: .domain)
      try container.encode(breachDateUnix, forKey: .breachDateUnix)
      try container.encode(details, forKey: .details)
      try container.encode(status, forKey: .status)
      try container.encode(uri, forKey: .uri)
      try container.encode(creationDateUnix, forKey: .creationDateUnix)
      try container.encodeIfPresent(updateDateUnix, forKey: .updateDateUnix)
      try container.encodeIfPresent(uuid, forKey: .uuid)
    }
  }
}
