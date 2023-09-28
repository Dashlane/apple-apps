import Foundation
extension AppAPIClient.DarkwebmonitoringQa {
        public struct SetTestDataBreach: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring-qa/SetTestDataBreach"

        public let api: AppAPIClient

                public func callAsFunction(databreach: Databreach, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(databreach: databreach)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var setTestDataBreach: SetTestDataBreach {
        SetTestDataBreach(api: api)
    }
}

extension AppAPIClient.DarkwebmonitoringQa.SetTestDataBreach {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case databreach = "databreach"
        }

        public let databreach: Databreach
    }

        public struct Databreach: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case uuid = "uuid"
            case breachDateUnix = "breachDateUnix"
            case details = "details"
            case domain = "domain"
        }

        public let uuid: String

        public let breachDateUnix: Int

        public let details: String?

        public let domain: String?

        public init(uuid: String, breachDateUnix: Int, details: String? = nil, domain: String? = nil) {
            self.uuid = uuid
            self.breachDateUnix = breachDateUnix
            self.details = details
            self.domain = domain
        }
    }
}

extension AppAPIClient.DarkwebmonitoringQa.SetTestDataBreach {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public enum Status: String, Codable, Equatable, CaseIterable {
            case staging = "staging"
            case live = "live"
            case pending = "pending"
            case hidden = "hidden"
        }

        private enum CodingKeys: String, CodingKey {
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

        public init(breachId: Int, livemode: Bool, domain: String?, breachDateUnix: Int, details: String, status: Status, uri: String?, creationDateUnix: Int, updateDateUnix: Int? = nil, uuid: String? = nil) {
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
    }
}
