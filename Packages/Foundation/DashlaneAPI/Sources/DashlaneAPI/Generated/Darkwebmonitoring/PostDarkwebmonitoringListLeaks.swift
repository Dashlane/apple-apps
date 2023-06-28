import Foundation
extension UserDeviceAPIClient.Darkwebmonitoring {
        public struct ListLeaks: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring/ListLeaks"

        public let api: UserDeviceAPIClient

                public func callAsFunction(includeDisabled: Bool? = nil, lastUpdateDate: Int? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(includeDisabled: includeDisabled, lastUpdateDate: lastUpdateDate)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var listLeaks: ListLeaks {
        ListLeaks(api: api)
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListLeaks {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case includeDisabled = "includeDisabled"
            case lastUpdateDate = "lastUpdateDate"
        }

                public let includeDisabled: Bool?

                public let lastUpdateDate: Int?
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListLeaks {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case lastUpdateDate = "lastUpdateDate"
            case details = "details"
            case emails = "emails"
            case leaks = "leaks"
        }

                public let lastUpdateDate: Int

        public let details: Details?

                public let emails: [DarkwebmonitoringListEmails]?

        public let leaks: [Leaks]?

                public struct Details: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case cipheredKey = "cipheredKey"
                case cipheredInfo = "cipheredInfo"
            }

            public let cipheredKey: String

            public let cipheredInfo: String

            public init(cipheredKey: String, cipheredInfo: String) {
                self.cipheredKey = cipheredKey
                self.cipheredInfo = cipheredInfo
            }
        }

                public struct Leaks: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case id = "id"
                case breachModelVersion = "breachModelVersion"
                case domains = "domains"
                case impactedEmails = "impactedEmails"
                case leakedData = "leakedData"
                case status = "status"
                case breachCreationDate = "breachCreationDate"
                case lastModificationRevision = "lastModificationRevision"
                case announcedDate = "announcedDate"
                case breachUpdateDate = "breachUpdateDate"
                case eventDate = "eventDate"
            }

            public let id: String

            public let breachModelVersion: Int

            public let domains: [String]

            public let impactedEmails: [String]

            public let leakedData: [String]

            public let status: String

            public let breachCreationDate: Int

            public let lastModificationRevision: Int

                        public let announcedDate: String?

            public let breachUpdateDate: Int?

                        public let eventDate: String?

            public init(id: String, breachModelVersion: Int, domains: [String], impactedEmails: [String], leakedData: [String], status: String, breachCreationDate: Int, lastModificationRevision: Int, announcedDate: String? = nil, breachUpdateDate: Int? = nil, eventDate: String? = nil) {
                self.id = id
                self.breachModelVersion = breachModelVersion
                self.domains = domains
                self.impactedEmails = impactedEmails
                self.leakedData = leakedData
                self.status = status
                self.breachCreationDate = breachCreationDate
                self.lastModificationRevision = lastModificationRevision
                self.announcedDate = announcedDate
                self.breachUpdateDate = breachUpdateDate
                self.eventDate = eventDate
            }
        }

        public init(lastUpdateDate: Int, details: Details? = nil, emails: [DarkwebmonitoringListEmails]? = nil, leaks: [Leaks]? = nil) {
            self.lastUpdateDate = lastUpdateDate
            self.details = details
            self.emails = emails
            self.leaks = leaks
        }
    }
}
