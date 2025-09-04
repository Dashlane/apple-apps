import Foundation

extension UserSecureNitroEncryptionAPIClient.Logs {
  public struct EncryptAuditLogDetailsBatchWithTeamKey: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/logs/EncryptAuditLogDetailsBatchWithTeamKey"

    public let api: UserSecureNitroEncryptionAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      detailsToEncryptBatch: [Body.DetailsToEncryptBatchElement], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(detailsToEncryptBatch: detailsToEncryptBatch)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var encryptAuditLogDetailsBatchWithTeamKey: EncryptAuditLogDetailsBatchWithTeamKey {
    EncryptAuditLogDetailsBatchWithTeamKey(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Logs.EncryptAuditLogDetailsBatchWithTeamKey {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case detailsToEncryptBatch = "detailsToEncryptBatch"
    }

    public struct DetailsToEncryptBatchElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case id = "id"
        case detailsToEncrypt = "detailsToEncrypt"
      }

      public struct DetailsToEncryptElement: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case key = "key"
          case value = "value"
        }

        public enum Key: String, Sendable, Hashable, Codable, CaseIterable {
          case domain = "domain"
          case domainURL = "domain_url"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let key: Key
        public let value: String

        public init(key: Key, value: String) {
          self.key = key
          self.value = value
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(key, forKey: .key)
          try container.encode(value, forKey: .value)
        }
      }

      public let id: String
      public let detailsToEncrypt: [DetailsToEncryptElement]

      public init(id: String, detailsToEncrypt: [DetailsToEncryptElement]) {
        self.id = id
        self.detailsToEncrypt = detailsToEncrypt
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(detailsToEncrypt, forKey: .detailsToEncrypt)
      }
    }

    public let detailsToEncryptBatch: [DetailsToEncryptBatchElement]

    public init(detailsToEncryptBatch: [DetailsToEncryptBatchElement]) {
      self.detailsToEncryptBatch = detailsToEncryptBatch
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(detailsToEncryptBatch, forKey: .detailsToEncryptBatch)
    }
  }
}

extension UserSecureNitroEncryptionAPIClient.Logs.EncryptAuditLogDetailsBatchWithTeamKey {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case encryptedDetailsBatch = "encryptedDetailsBatch"
    }

    public struct EncryptedDetailsBatchElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case id = "id"
        case encryptedDetails = "encryptedDetails"
      }

      public let id: String
      public let encryptedDetails: String

      public init(id: String, encryptedDetails: String) {
        self.id = id
        self.encryptedDetails = encryptedDetails
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(encryptedDetails, forKey: .encryptedDetails)
      }
    }

    public let encryptedDetailsBatch: [EncryptedDetailsBatchElement]

    public init(encryptedDetailsBatch: [EncryptedDetailsBatchElement]) {
      self.encryptedDetailsBatch = encryptedDetailsBatch
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(encryptedDetailsBatch, forKey: .encryptedDetailsBatch)
    }
  }
}
