import Foundation
extension AppAPIClient.Breaches {
        public struct ListBreaches: APIRequest {
        public static let endpoint: Endpoint = "/breaches/ListBreaches"

        public let api: AppAPIClient

                public func callAsFunction(livemode: Bool, pageCount: Int, pageNumber: Int, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(livemode: livemode, pageCount: pageCount, pageNumber: pageNumber)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var listBreaches: ListBreaches {
        ListBreaches(api: api)
    }
}

extension AppAPIClient.Breaches.ListBreaches {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case livemode = "livemode"
            case pageCount = "pageCount"
            case pageNumber = "pageNumber"
        }

                public let livemode: Bool

                public let pageCount: Int

                public let pageNumber: Int
    }
}

extension AppAPIClient.Breaches.ListBreaches {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case breaches = "breaches"
        }

        public let breaches: [Breaches]?

                public struct Breaches: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case creationDateUnix = "creationDateUnix"
                case definition = "definition"
                case deletionDateUnix = "deletionDateUnix"
                case id = "id"
                case livemode = "livemode"
                case revision = "revision"
                case updateDateUnix = "updateDateUnix"
                case uri = "uri"
            }

            public let creationDateUnix: Int

            public let definition: Definition

                        public let deletionDateUnix: Int?

                        public let id: Int

                        public let livemode: Bool

                        public let revision: Int

                        public let updateDateUnix: Int?

                        public let uri: String

                        public struct Definition: Codable, Equatable {

                                public enum Criticality: Int, Codable, Equatable, CaseIterable {
                    case _1 = 1
                    case _2 = 2
                    case _3 = 3
                }

                private enum CodingKeys: String, CodingKey {
                    case announcedDate = "announcedDate"
                    case breachModelVersion = "breachModelVersion"
                    case criticality = "criticality"
                    case domains = "domains"
                    case eventDate = "eventDate"
                    case id = "id"
                    case leakedData = "leakedData"
                    case name = "name"
                    case sensitiveDomain = "sensitiveDomain"
                    case status = "status"
                    case template = "template"
                    case breachCreationDate = "breachCreationDate"
                    case lastModificationRevision = "lastModificationRevision"
                    case relatedLinks = "relatedLinks"
                }

                                public let announcedDate: DateDay

                                public let breachModelVersion: Int

                                public let criticality: Criticality

                                public let domains: [String]

                                public let eventDate: String

                public let id: String

                                public let leakedData: [String]

                                public let name: String

                                public let sensitiveDomain: Bool

                public let status: BreachesStatus

                                public let template: String

                                public let breachCreationDate: Int?

                                public let lastModificationRevision: Int?

                public let relatedLinks: [URL]?

                public init(announcedDate: DateDay, breachModelVersion: Int, criticality: Criticality, domains: [String], eventDate: String, id: String, leakedData: [String], name: String, sensitiveDomain: Bool, status: BreachesStatus, template: String, breachCreationDate: Int? = nil, lastModificationRevision: Int? = nil, relatedLinks: [URL]? = nil) {
                    self.announcedDate = announcedDate
                    self.breachModelVersion = breachModelVersion
                    self.criticality = criticality
                    self.domains = domains
                    self.eventDate = eventDate
                    self.id = id
                    self.leakedData = leakedData
                    self.name = name
                    self.sensitiveDomain = sensitiveDomain
                    self.status = status
                    self.template = template
                    self.breachCreationDate = breachCreationDate
                    self.lastModificationRevision = lastModificationRevision
                    self.relatedLinks = relatedLinks
                }
            }

            public init(creationDateUnix: Int, definition: Definition, deletionDateUnix: Int?, id: Int, livemode: Bool, revision: Int, updateDateUnix: Int?, uri: String) {
                self.creationDateUnix = creationDateUnix
                self.definition = definition
                self.deletionDateUnix = deletionDateUnix
                self.id = id
                self.livemode = livemode
                self.revision = revision
                self.updateDateUnix = updateDateUnix
                self.uri = uri
            }
        }

        public init(breaches: [Breaches]? = nil) {
            self.breaches = breaches
        }
    }
}
