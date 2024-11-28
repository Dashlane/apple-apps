import Foundation

extension UserSecureNitroEncryptionAPIClient.Logs {
  public struct StoreAuditLogs: APIRequest {
    public static let endpoint: Endpoint = "/logs/StoreAuditLogs"

    public let api: UserSecureNitroEncryptionAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(auditLogs: [Body.AuditLogsElement], timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(auditLogs: auditLogs)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var storeAuditLogs: StoreAuditLogs {
    StoreAuditLogs(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case auditLogs = "auditLogs"
    }

    public struct AuditLogsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case uuid = "uuid"
        case logType = "log_type"
        case dateTime = "date_time"
        case properties = "properties"
      }

      public enum SchemaVersion: String, Sendable, Equatable, CaseIterable, Codable {
        case one00 = "1.0.0"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public enum LogType: String, Sendable, Equatable, CaseIterable, Codable {
        case userCreatedCredential = "user_created_credential"
        case userCreatedSecureNote = "user_created_secure_note"
        case userDeletedCredential = "user_deleted_credential"
        case userDeletedSecureNote = "user_deleted_secure_note"
        case userImportedCredentials = "user_imported_credentials"
        case userModifiedCredential = "user_modified_credential"
        case userModifiedSecureNote = "user_modified_secure_note"
        case userCreatedCollection = "user_created_collection"
        case userImportedCollection = "user_imported_collection"
        case userAddedCredentialToCollection = "user_added_credential_to_collection"
        case userRemovedCredentialFromCollection = "user_removed_credential_from_collection"
        case userAddedSecureNoteToCollection = "user_added_secure_note_to_collection"
        case userRemovedSecureNoteFromCollection = "user_removed_secure_note_from_collection"
        case userRenamedCollection = "user_renamed_collection"
        case userDeletedCollection = "user_deleted_collection"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public struct Properties: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case collectionName = "collection_name"
          case credentialCount = "credential_count"
          case domainURL = "domain_url"
          case importCount = "import_count"
          case oldCollectionName = "old_collection_name"
        }

        public let collectionName: String?
        public let credentialCount: Int?
        public let domainURL: String?
        public let importCount: Int?
        public let oldCollectionName: String?

        public init(
          collectionName: String? = nil, credentialCount: Int? = nil, domainURL: String? = nil,
          importCount: Int? = nil, oldCollectionName: String? = nil
        ) {
          self.collectionName = collectionName
          self.credentialCount = credentialCount
          self.domainURL = domainURL
          self.importCount = importCount
          self.oldCollectionName = oldCollectionName
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(collectionName, forKey: .collectionName)
          try container.encodeIfPresent(credentialCount, forKey: .credentialCount)
          try container.encodeIfPresent(domainURL, forKey: .domainURL)
          try container.encodeIfPresent(importCount, forKey: .importCount)
          try container.encodeIfPresent(oldCollectionName, forKey: .oldCollectionName)
        }
      }

      public let schemaVersion: SchemaVersion
      public let uuid: String
      public let logType: LogType
      public let dateTime: Int
      public let properties: Properties

      public init(
        schemaVersion: SchemaVersion, uuid: String, logType: LogType, dateTime: Int,
        properties: Properties
      ) {
        self.schemaVersion = schemaVersion
        self.uuid = uuid
        self.logType = logType
        self.dateTime = dateTime
        self.properties = properties
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(logType, forKey: .logType)
        try container.encode(dateTime, forKey: .dateTime)
        try container.encode(properties, forKey: .properties)
      }
    }

    public let auditLogs: [AuditLogsElement]

    public init(auditLogs: [AuditLogsElement]) {
      self.auditLogs = auditLogs
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(auditLogs, forKey: .auditLogs)
    }
  }
}

extension UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case invalidAuditLogs = "invalidAuditLogs"
    }

    public struct InvalidAuditLogsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case error = "error"
      }

      public enum Error: String, Sendable, Equatable, CaseIterable, Codable {
        case auditLogMissingJsonSchema = "AUDIT_LOG_MISSING_JSON_SCHEMA"
        case auditLogInvalidJsonForJsonSchema = "AUDIT_LOG_INVALID_JSON_FOR_JSON_SCHEMA"
        case auditLogInvalidLogSchemaTypeOrVersion = "AUDIT_LOG_INVALID_LOG_SCHEMA_TYPE_OR_VERSION"
        case auditLogErrorReadingJsonSchema = "AUDIT_LOG_ERROR_READING_JSON_SCHEMA"
        case storingSensitiveAuditLogsNotAllowed = "STORING_SENSITIVE_AUDIT_LOGS_NOT_ALLOWED"
        case auditLogTypeNotClientSide = "AUDIT_LOG_TYPE_NOT_CLIENT_SIDE"
        case auditLogTypeNotTeamDeviceOrClientSide = "AUDIT_LOG_TYPE_NOT_TEAM_DEVICE_OR_CLIENT_SIDE"
        case auditLogMissingCategoryToLogTypeMapping =
          "AUDIT_LOG_MISSING_CATEGORY_TO_LOG_TYPE_MAPPING"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let uuid: String
      public let error: Error

      public init(uuid: String, error: Error) {
        self.uuid = uuid
        self.error = error
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(error, forKey: .error)
      }
    }

    public let invalidAuditLogs: [InvalidAuditLogsElement]

    public init(invalidAuditLogs: [InvalidAuditLogsElement]) {
      self.invalidAuditLogs = invalidAuditLogs
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(invalidAuditLogs, forKey: .invalidAuditLogs)
    }
  }
}
