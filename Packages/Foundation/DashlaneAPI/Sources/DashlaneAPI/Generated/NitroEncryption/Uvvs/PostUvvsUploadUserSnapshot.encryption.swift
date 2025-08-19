import Foundation

extension UserSecureNitroEncryptionAPIClient.Uvvs {
  public struct UploadUserSnapshot: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/uvvs/UploadUserSnapshot"

    public let api: UserSecureNitroEncryptionAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      uvvs: [Body.UvvsElement], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(uvvs: uvvs)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var uploadUserSnapshot: UploadUserSnapshot {
    UploadUserSnapshot(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Uvvs.UploadUserSnapshot {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case uvvs = "uvvs"
    }

    public struct UvvsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case id = "id"
        case domain = "domain"
        case creationDateUnix = "creationDateUnix"
        case risks = "risks"
      }

      public struct Risks: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case isWeak = "isWeak"
          case isReused = "isReused"
          case isCompromised = "isCompromised"
        }

        public let isWeak: Bool
        public let isReused: Bool
        public let isCompromised: Bool

        public init(isWeak: Bool, isReused: Bool, isCompromised: Bool) {
          self.isWeak = isWeak
          self.isReused = isReused
          self.isCompromised = isCompromised
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(isWeak, forKey: .isWeak)
          try container.encode(isReused, forKey: .isReused)
          try container.encode(isCompromised, forKey: .isCompromised)
        }
      }

      public let id: String
      public let domain: String
      public let creationDateUnix: Int
      public let risks: Risks?

      public init(id: String, domain: String, creationDateUnix: Int, risks: Risks? = nil) {
        self.id = id
        self.domain = domain
        self.creationDateUnix = creationDateUnix
        self.risks = risks
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(domain, forKey: .domain)
        try container.encode(creationDateUnix, forKey: .creationDateUnix)
        try container.encodeIfPresent(risks, forKey: .risks)
      }
    }

    public let uvvs: [UvvsElement]

    public init(uvvs: [UvvsElement]) {
      self.uvvs = uvvs
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(uvvs, forKey: .uvvs)
    }
  }
}

extension UserSecureNitroEncryptionAPIClient.Uvvs.UploadUserSnapshot {
  public typealias Response = Empty?
}
