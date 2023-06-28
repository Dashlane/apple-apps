import Foundation
extension UserDeviceAPIClient.Teams {
        public struct StoreActivityLogs: APIRequest {
        public static let endpoint: Endpoint = "/teams/StoreActivityLogs"

        public let api: UserDeviceAPIClient

                public func callAsFunction(activityLogs: [ActivityLogs], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(activityLogs: activityLogs)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var storeActivityLogs: StoreActivityLogs {
        StoreActivityLogs(api: api)
    }
}

extension UserDeviceAPIClient.Teams.StoreActivityLogs {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case activityLogs = "activityLogs"
        }

                public let activityLogs: [ActivityLogs]
    }

        public struct ActivityLogs: Codable, Equatable {

                public enum LogType: String, Codable, Equatable, CaseIterable {
            case userCreatedCredential = "user_created_credential"
            case userCreatedSecureNote = "user_created_secure_note"
            case userDeletedCredential = "user_deleted_credential"
            case userDeletedSecureNote = "user_deleted_secure_note"
            case userImportedCredentials = "user_imported_credentials"
            case userModifiedCredential = "user_modified_credential"
            case userModifiedSecureNote = "user_modified_secure_note"
        }

                public enum SchemaVersion: String, Codable, Equatable, CaseIterable {
            case _100 = "1.0.0"
        }

        private enum CodingKeys: String, CodingKey {
            case dateTime = "date_time"
            case logType = "log_type"
            case properties = "properties"
            case schemaVersion = "schema_version"
            case uuid = "uuid"
        }

                public let dateTime: Int

        public let logType: LogType

        public let properties: Properties

        public let schemaVersion: SchemaVersion

                public let uuid: String

                public struct Properties: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case domainURL = "domain_url"
                case importCount = "import_count"
            }

                        public let domainURL: String?

                        public let importCount: Int?

            public init(domainURL: String? = nil, importCount: Int? = nil) {
                self.domainURL = domainURL
                self.importCount = importCount
            }
        }

        public init(dateTime: Int, logType: LogType, properties: Properties, schemaVersion: SchemaVersion, uuid: String) {
            self.dateTime = dateTime
            self.logType = logType
            self.properties = properties
            self.schemaVersion = schemaVersion
            self.uuid = uuid
        }
    }
}

extension UserDeviceAPIClient.Teams.StoreActivityLogs {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case invalidActivityLogs = "invalidActivityLogs"
        }

                public let invalidActivityLogs: [InvalidActivityLogs]

                public struct InvalidActivityLogs: Codable, Equatable {

                        public enum ErrorType: String, Codable, Equatable, CaseIterable {
                case auditLogMissingJsonSchema = "AUDIT_LOG_MISSING_JSON_SCHEMA"
                case auditLogInvalidJsonForJsonSchema = "AUDIT_LOG_INVALID_JSON_FOR_JSON_SCHEMA"
                case auditLogInvalidLogSchemaTypeOrVersion = "AUDIT_LOG_INVALID_LOG_SCHEMA_TYPE_OR_VERSION"
                case auditLogErrorReadingJsonSchema = "AUDIT_LOG_ERROR_READING_JSON_SCHEMA"
                case storingSensitiveAuditLogsNotAllowed = "STORING_SENSITIVE_AUDIT_LOGS_NOT_ALLOWED"
            }

            private enum CodingKeys: String, CodingKey {
                case uuid = "uuid"
                case error = "error"
            }

            public let uuid: String

            public let error: ErrorType

            public init(uuid: String, error: ErrorType) {
                self.uuid = uuid
                self.error = error
            }
        }

        public init(invalidActivityLogs: [InvalidActivityLogs]) {
            self.invalidActivityLogs = invalidActivityLogs
        }
    }
}
