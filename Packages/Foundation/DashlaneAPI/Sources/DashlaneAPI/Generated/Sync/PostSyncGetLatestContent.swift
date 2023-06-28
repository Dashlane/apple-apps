import Foundation
extension UserDeviceAPIClient.Sync {
        public struct GetLatestContent: APIRequest {
        public static let endpoint: Endpoint = "/sync/GetLatestContent"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timestamp: Int, transactions: [String], needsKeys: Bool, teamAdminGroups: Bool, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(timestamp: timestamp, transactions: transactions, needsKeys: needsKeys, teamAdminGroups: teamAdminGroups)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getLatestContent: GetLatestContent {
        GetLatestContent(api: api)
    }
}

extension UserDeviceAPIClient.Sync.GetLatestContent {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case timestamp = "timestamp"
            case transactions = "transactions"
            case needsKeys = "needsKeys"
            case teamAdminGroups = "teamAdminGroups"
        }

                public let timestamp: Int

                public let transactions: [String]

                public let needsKeys: Bool

                public let teamAdminGroups: Bool
    }
}

extension UserDeviceAPIClient.Sync.GetLatestContent {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case transactions = "transactions"
            case timestamp = "timestamp"
            case sharing2 = "sharing2"
            case syncAllowed = "syncAllowed"
            case uploadEnabled = "uploadEnabled"
            case summary = "summary"
            case fullBackup = "fullBackup"
            case keys = "keys"
        }

                public let transactions: [Transactions]

                public let timestamp: Int

        public let sharing2: Sharing2

                public let syncAllowed: Bool

                public let uploadEnabled: Bool

        public let summary: [String: [String: Int]]

                public let fullBackup: [String: Empty?]?

                public let keys: Keys?

                public struct Transactions: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case action = "action"
                case backupDate = "backupDate"
                case identifier = "identifier"
                case time = "time"
                case type = "type"
                case content = "content"
            }

            public let action: SyncContentAction

                        public let backupDate: Int

                        public let identifier: String

                        public let time: Int

                        public let type: String

                        public let content: String?

            public init(action: SyncContentAction, backupDate: Int, identifier: String, time: Int, type: String, content: String? = nil) {
                self.action = action
                self.backupDate = backupDate
                self.identifier = identifier
                self.time = time
                self.type = type
                self.content = content
            }
        }

                public struct Sharing2: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case itemGroups = "itemGroups"
                case items = "items"
                case userGroups = "userGroups"
            }

            public let itemGroups: [SyncGetLatestContentGroups]

            public let items: [Items]

            public let userGroups: [SyncGetLatestContentGroups]

                        public struct Items: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case id = "id"
                    case timestamp = "timestamp"
                }

                public let id: String

                public let timestamp: Int

                public init(id: String, timestamp: Int) {
                    self.id = id
                    self.timestamp = timestamp
                }
            }

            public init(itemGroups: [SyncGetLatestContentGroups], items: [Items], userGroups: [SyncGetLatestContentGroups]) {
                self.itemGroups = itemGroups
                self.items = items
                self.userGroups = userGroups
            }
        }

                public struct Keys: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case publicKey = "publicKey"
                case privateKey = "privateKey"
            }

            public let publicKey: String

            public let privateKey: String

            public init(publicKey: String, privateKey: String) {
                self.publicKey = publicKey
                self.privateKey = privateKey
            }
        }

        public init(transactions: [Transactions], timestamp: Int, sharing2: Sharing2, syncAllowed: Bool, uploadEnabled: Bool, summary: [String: [String: Int]], fullBackup: [String: Empty?]? = nil, keys: Keys? = nil) {
            self.transactions = transactions
            self.timestamp = timestamp
            self.sharing2 = sharing2
            self.syncAllowed = syncAllowed
            self.uploadEnabled = uploadEnabled
            self.summary = summary
            self.fullBackup = fullBackup
            self.keys = keys
        }
    }
}
