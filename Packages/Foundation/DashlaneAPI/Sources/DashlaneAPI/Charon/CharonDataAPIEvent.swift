import Foundation

public extension CharonDataAPIClient {

    struct Event<Properties: Codable>: Codable {
        public var id: String?
        public var schemaVersion: String?
        public var date: String?
        public var dateOrigin: String?
        public var category: String?
        public var context: Context?
        public var browse: Browse?
        public var session: Session?
        public var properties: Properties?

        public init(id: String? = nil, schemaVersion: String? = nil, date: String? = nil, dateOrigin: String? = nil, category: String? = nil, context: Context? = nil, browse: Browse? = nil, session: Session? = nil, properties: Properties? = nil) {
            self.id = id
            self.schemaVersion = schemaVersion
            self.date = date
            self.dateOrigin = dateOrigin
            self.category = category
            self.context = context
            self.browse = browse
            self.session = session
            self.properties = properties
        }
    }

    struct CharonResult<PropertiesCodable: Codable>: Codable {
        public var errorCount: Int?
        public var errors: CharonErrors?
        public var event: Event<PropertiesCodable>

        public init(errorCount: Int, errors: CharonErrors, event: Event<PropertiesCodable>) {
            self.errorCount = errorCount
            self.errors = errors
            self.event = event
        }

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CharonDataAPIClient.CharonResult<PropertiesCodable>.CodingKeys> = try decoder.container(keyedBy: CharonDataAPIClient.CharonResult<PropertiesCodable>.CodingKeys.self)
            self.errorCount = try container.decodeIfPresent(Int.self, forKey: CharonDataAPIClient.CharonResult<PropertiesCodable>.CodingKeys.errorCount)
            if let errors = try? container.decode([CharonDataAPIClient.Errors?].self, forKey: CharonDataAPIClient.CharonResult<PropertiesCodable>.CodingKeys.errors) {
                self.errors = .errors(errors)
            } else if let strings = try? container.decode([String].self, forKey: CharonDataAPIClient.CharonResult<PropertiesCodable>.CodingKeys.errors) {
                self.errors = .strs(strings)
                            }
            self.event = try container.decode(CharonDataAPIClient.Event<PropertiesCodable>.self, forKey: CharonDataAPIClient.CharonResult<PropertiesCodable>.CodingKeys.event)
        }
    }

    enum CharonErrors: Codable {
        case errors([Errors?])
        case strs([String])
    }

    struct NestedResult: Codable {
        public var errorCount: Int?
        public var event: Event<CharonDataAPIClient.Properties.Empty>

        public init(errorCount: Int, event: Event<CharonDataAPIClient.Properties.Empty>) {
            self.errorCount = errorCount
            self.event = event
        }
    }

    struct Errors: Codable {
        public var mismatchedFields: MismatchedFields?
        public var logNotFound: Event<CharonDataAPIClient.Properties.Empty>?
        public var extraLogs: [NestedResult]?
    }

    struct MismatchedFields: Codable {
        public var wrongValues: [WrongValues]?
    }

    struct WrongValues: Codable {
        public var field: String?
        public var expected: String?
        public var actual: String?
    }

    struct CharonResponse<PropertiesCodable: Codable>: Codable {
        public var result: [CharonResult<PropertiesCodable>]?
        public var success: Bool
        public var error: String?
        public var errors: Errors?

        public init(result: [CharonResult<PropertiesCodable>], success: Bool, error: String?, errors: Errors?) {
            self.result = result
            self.success = success
            self.error = error
            self.errors = errors
        }

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CharonDataAPIClient.CharonResponse<PropertiesCodable>.CodingKeys> = try decoder.container(keyedBy: CharonDataAPIClient.CharonResponse<PropertiesCodable>.CodingKeys.self)
            if let result = try? container.decode([CharonResult<PropertiesCodable>].self, forKey: .result) {
                self.result = result
            } 
            self.success = try container.decode(Bool.self, forKey: CharonDataAPIClient.CharonResponse<PropertiesCodable>.CodingKeys.success)
            self.error = try container.decodeIfPresent(String.self, forKey: CharonDataAPIClient.CharonResponse<PropertiesCodable>.CodingKeys.error)
            self.errors = try container.decodeIfPresent(CharonDataAPIClient.Errors.self, forKey: CharonDataAPIClient.CharonResponse<PropertiesCodable>.CodingKeys.errors)
        }

    }

    struct Domain: Codable {
        public var id: String?
        public var type: String?

        public init(id: String? = nil, type: String? = nil) {
            self.id = id
            self.type = type
        }
    }

    struct Context: Codable {
        public var user: User?
        public var device: DeviceTrackingEvents?
        public var app: App?

        public init(user: User? = nil, device: DeviceTrackingEvents? = nil, app: App? = nil) {
            self.user = user
            self.device = device
            self.app = app
        }
    }

    struct User: Codable {
        public var id: String?

        public init(id: String? = nil) {
            self.id = id
        }
    }

    struct DeviceTrackingEvents: Codable {
        public var installationId: String?
        public var id: String?
        public var os: DeviceOS?

        public init(installationId: String? = nil, id: String? = nil, os: DeviceOS? = nil) {
            self.installationId = installationId
            self.id = id
            self.os = os
        }
    }

    struct DeviceOS: Codable {
        public var type: String?
        public var version: String?
        public var locale: String?

        public init(type: String? = nil, version: String? = nil, locale: String? = nil) {
            self.type = type
            self.version = version
            self.locale = locale
        }
    }

    struct App: Codable {
        public var version: String?
        public var platform: String?
        public var buildType: String?

        public init(version: String? = nil, platform: String? = nil, buildType: String? = nil) {
            self.version = version
            self.platform = platform
            self.buildType = buildType
        }
    }

    struct Browse: Codable {
        public var component: String?
        public var originComponent: String?
        public var originPage: String?
        public var page: String?

        public init(component: String? = nil, originComponent: String? = nil, originPage: String? = nil, page: String? = nil) {
            self.component = component
            self.originComponent = originComponent
            self.originPage = originPage
            self.page = page
        }
    }

    struct Session: Codable {
        public var id: String?
        public var sequenceNumber: Int?

        public init(id: String? = nil, sequenceNumber: Int? = nil) {
            self.id = id
            self.sequenceNumber = sequenceNumber
        }
    }

}
