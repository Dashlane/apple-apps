import Foundation
extension UserDeviceAPIClient.Breaches {
        public struct GetBreach: APIRequest {
        public static let endpoint: Endpoint = "/breaches/GetBreach"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getBreach: GetBreach {
        GetBreach(api: api)
    }
}

extension UserDeviceAPIClient.Breaches.GetBreach {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
        }

                public let revision: Int
    }
}

extension UserDeviceAPIClient.Breaches.GetBreach {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case latestBreaches = "latestBreaches"
            case filesToDownload = "filesToDownload"
        }

                public let revision: Int

        public let latestBreaches: [LatestBreaches]

                public let filesToDownload: [String]?

                public struct LatestBreaches: Codable, Equatable {

                        public enum Criticality: Int, Codable, Equatable, CaseIterable {
                case _1 = 1
                case _2 = 2
                case _3 = 3
            }

            private enum CodingKeys: String, CodingKey {
                case announcedDate = "announcedDate"
                case breachCreationDate = "breachCreationDate"
                case breachModelVersion = "breachModelVersion"
                case criticality = "criticality"
                case description = "description"
                case domains = "domains"
                case eventDate = "eventDate"
                case id = "id"
                case lastModificationRevision = "lastModificationRevision"
                case leakedData = "leakedData"
                case name = "name"
                case relatedLinks = "relatedLinks"
                case restrictedArea = "restrictedArea"
                case sensitiveDomain = "sensitiveDomain"
                case status = "status"
                case template = "template"
            }

                        public let announcedDate: DateDay?

                        public let breachCreationDate: Int?

                        public let breachModelVersion: Int?

                        public let criticality: Criticality?

                        public let description: Description?

                        public let domains: [String]?

                        public let eventDate: String?

                        public let id: String?

                        public let lastModificationRevision: Int?

                        public let leakedData: [String]?

                        public let name: String?

            public let relatedLinks: [URL]?

            public let restrictedArea: [String]?

            public let sensitiveDomain: Bool?

            public let status: BreachesStatus?

                        public let template: String?

                        public struct Description: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case en = "en"
                }

                                public let en: String?

                public init(en: String? = nil) {
                    self.en = en
                }
            }

            public init(announcedDate: DateDay? = nil, breachCreationDate: Int? = nil, breachModelVersion: Int? = nil, criticality: Criticality? = nil, description: Description? = nil, domains: [String]? = nil, eventDate: String? = nil, id: String? = nil, lastModificationRevision: Int? = nil, leakedData: [String]? = nil, name: String? = nil, relatedLinks: [URL]? = nil, restrictedArea: [String]? = nil, sensitiveDomain: Bool? = nil, status: BreachesStatus? = nil, template: String? = nil) {
                self.announcedDate = announcedDate
                self.breachCreationDate = breachCreationDate
                self.breachModelVersion = breachModelVersion
                self.criticality = criticality
                self.description = description
                self.domains = domains
                self.eventDate = eventDate
                self.id = id
                self.lastModificationRevision = lastModificationRevision
                self.leakedData = leakedData
                self.name = name
                self.relatedLinks = relatedLinks
                self.restrictedArea = restrictedArea
                self.sensitiveDomain = sensitiveDomain
                self.status = status
                self.template = template
            }
        }

        public init(revision: Int, latestBreaches: [LatestBreaches], filesToDownload: [String]? = nil) {
            self.revision = revision
            self.latestBreaches = latestBreaches
            self.filesToDownload = filesToDownload
        }
    }
}
