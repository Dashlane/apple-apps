import Foundation

extension UserSecureNitroEncryptionAPIClient.Logs {
  public struct StoreAuditLogs: APIRequest, Sendable {
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
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case auditLogs = "auditLogs"
    }

    public struct AuditLogsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case uuid = "uuid"
        case logType = "log_type"
        case dateTime = "date_time"
        case properties = "properties"
      }

      public enum SchemaVersion: String, Sendable, Hashable, Codable, CaseIterable {
        case one00 = "1.0.0"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public enum LogType: String, Sendable, Hashable, Codable, CaseIterable {
        case userAddedCredentialToCollection = "user_added_credential_to_collection"
        case userAddedSecureNoteToCollection = "user_added_secure_note_to_collection"
        case userAuthenticatedWithPasskey = "user_authenticated_with_passkey"
        case userCopiedBankAccountField = "user_copied_bank_account_field"
        case userCopiedCredentialField = "user_copied_credential_field"
        case userCopiedCreditCardField = "user_copied_credit_card_field"
        case userCopiedSecretField = "user_copied_secret_field"
        case userCopiedSecureNoteField = "user_copied_secure_note_field"
        case userCreatedCollection = "user_created_collection"
        case userCreatedCredential = "user_created_credential"
        case userCreatedSecureNote = "user_created_secure_note"
        case userDeletedCollection = "user_deleted_collection"
        case userDeletedCredential = "user_deleted_credential"
        case userDeletedSecureNote = "user_deleted_secure_note"
        case userExcludedItemFromPasswordHealth = "user_excluded_item_from_password_health"
        case userImportedCollection = "user_imported_collection"
        case userImportedCredentials = "user_imported_credentials"
        case userIncludedItemInPasswordHealth = "user_included_item_in_password_health"
        case userModifiedCredential = "user_modified_credential"
        case userModifiedSecureNote = "user_modified_secure_note"
        case userPerformedAutofillCredential = "user_performed_autofill_credential"
        case userPerformedAutofillPayment = "user_performed_autofill_payment"
        case userRemovedCredentialFromCollection = "user_removed_credential_from_collection"
        case userRemovedSecureNoteFromCollection = "user_removed_secure_note_from_collection"
        case userRenamedCollection = "user_renamed_collection"
        case userRevealedBankAccountField = "user_revealed_bank_account_field"
        case userRevealedCredentialField = "user_revealed_credential_field"
        case userRevealedCreditCardField = "user_revealed_credit_card_field"
        case userRevealedSecretField = "user_revealed_secret_field"
        case userRevealedSecureNoteField = "user_revealed_secure_note_field"
        case userTypedCompromisedPassword = "user_typed_compromised_password"
        case userTypedPassword = "user_typed_password"
        case userTypedWeakPassword = "user_typed_weak_password"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public struct Properties: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case autofilledDomain = "autofilled_domain"
          case collectionName = "collection_name"
          case credentialCount = "credential_count"
          case credentialDomain = "credential_domain"
          case credentialLogin = "credential_login"
          case currentDomain = "current_domain"
          case domainURL = "domain_url"
          case field = "field"
          case healthStatus = "health_status"
          case importCount = "import_count"
          case itemName = "item_name"
          case itemType = "item_type"
          case name = "name"
          case oldCollectionName = "old_collection_name"
          case passkeyDomain = "passkey_domain"
        }

        public enum Field: String, Sendable, Hashable, Codable, CaseIterable {
          case iban = "iban"
          case swift = "swift"
          case sortCode = "sort_code"
          case accountNumber = "account_number"
          case routingNumber = "routing_number"
          case password = "password"
          case otp = "otp"
          case number = "number"
          case cvv = "cvv"
          case expirationDate = "expiration_date"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public enum HealthStatus: String, Sendable, Hashable, Codable, CaseIterable {
          case safe = "safe"
          case weak = "weak"
          case compromised = "compromised"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public enum ItemType: String, Sendable, Hashable, Codable, CaseIterable {
          case creditCard = "credit_card"
          case bankAccount = "bank_account"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let autofilledDomain: String?
        public let collectionName: String?
        public let credentialCount: Int?
        public let credentialDomain: String?
        public let credentialLogin: String?
        public let currentDomain: String?
        public let domainURL: String?
        public let field: Field?
        public let healthStatus: HealthStatus?
        public let importCount: Int?
        public let itemName: String?
        public let itemType: ItemType?
        public let name: String?
        public let oldCollectionName: String?
        public let passkeyDomain: String?

        public init(
          autofilledDomain: String? = nil, collectionName: String? = nil,
          credentialCount: Int? = nil, credentialDomain: String? = nil,
          credentialLogin: String? = nil, currentDomain: String? = nil, domainURL: String? = nil,
          field: Field? = nil, healthStatus: HealthStatus? = nil, importCount: Int? = nil,
          itemName: String? = nil, itemType: ItemType? = nil, name: String? = nil,
          oldCollectionName: String? = nil, passkeyDomain: String? = nil
        ) {
          self.autofilledDomain = autofilledDomain
          self.collectionName = collectionName
          self.credentialCount = credentialCount
          self.credentialDomain = credentialDomain
          self.credentialLogin = credentialLogin
          self.currentDomain = currentDomain
          self.domainURL = domainURL
          self.field = field
          self.healthStatus = healthStatus
          self.importCount = importCount
          self.itemName = itemName
          self.itemType = itemType
          self.name = name
          self.oldCollectionName = oldCollectionName
          self.passkeyDomain = passkeyDomain
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(autofilledDomain, forKey: .autofilledDomain)
          try container.encodeIfPresent(collectionName, forKey: .collectionName)
          try container.encodeIfPresent(credentialCount, forKey: .credentialCount)
          try container.encodeIfPresent(credentialDomain, forKey: .credentialDomain)
          try container.encodeIfPresent(credentialLogin, forKey: .credentialLogin)
          try container.encodeIfPresent(currentDomain, forKey: .currentDomain)
          try container.encodeIfPresent(domainURL, forKey: .domainURL)
          try container.encodeIfPresent(field, forKey: .field)
          try container.encodeIfPresent(healthStatus, forKey: .healthStatus)
          try container.encodeIfPresent(importCount, forKey: .importCount)
          try container.encodeIfPresent(itemName, forKey: .itemName)
          try container.encodeIfPresent(itemType, forKey: .itemType)
          try container.encodeIfPresent(name, forKey: .name)
          try container.encodeIfPresent(oldCollectionName, forKey: .oldCollectionName)
          try container.encodeIfPresent(passkeyDomain, forKey: .passkeyDomain)
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
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case invalidAuditLogs = "invalidAuditLogs"
    }

    public struct InvalidAuditLogsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case error = "error"
      }

      public enum Error: String, Sendable, Hashable, Codable, CaseIterable {
        case auditLogMissingJsonSchema = "AUDIT_LOG_MISSING_JSON_SCHEMA"
        case auditLogInvalidJsonForJsonSchema = "AUDIT_LOG_INVALID_JSON_FOR_JSON_SCHEMA"
        case auditLogInvalidLogSchemaTypeOrVersion = "AUDIT_LOG_INVALID_LOG_SCHEMA_TYPE_OR_VERSION"
        case auditLogErrorReadingJsonSchema = "AUDIT_LOG_ERROR_READING_JSON_SCHEMA"
        case storingSensitiveAuditLogsNotAllowed = "STORING_SENSITIVE_AUDIT_LOGS_NOT_ALLOWED"
        case auditLogTypeNotClientSide = "AUDIT_LOG_TYPE_NOT_CLIENT_SIDE"
        case auditLogTypeNotAllowedForMassDeploymentTeamKeyAuth =
          "AUDIT_LOG_TYPE_NOT_ALLOWED_FOR_MASS_DEPLOYMENT_TEAM_KEY_AUTH"
        case auditLogTypeNotAllowedWithCredentialRiskDetectionDisabled =
          "AUDIT_LOG_TYPE_NOT_ALLOWED_WITH_CREDENTIAL_RISK_DETECTION_DISABLED"
        case auditLogTypeNotTeamDeviceOrClientSide = "AUDIT_LOG_TYPE_NOT_TEAM_DEVICE_OR_CLIENT_SIDE"
        case auditLogMissingCategoryToLogTypeMapping =
          "AUDIT_LOG_MISSING_CATEGORY_TO_LOG_TYPE_MAPPING"
        case auditLogStoreInternalError = "AUDIT_LOG_STORE_INTERNAL_ERROR"
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
