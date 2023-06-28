import Foundation
extension UserDeviceAPIClient.Sync {
        public struct UploadContent: APIRequest {
        public static let endpoint: Endpoint = "/sync/UploadContent"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timestamp: Int, transactions: [Transactions], sharingKeys: SyncSharingKeys? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(timestamp: timestamp, transactions: transactions, sharingKeys: sharingKeys)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var uploadContent: UploadContent {
        UploadContent(api: api)
    }
}

extension UserDeviceAPIClient.Sync.UploadContent {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case timestamp = "timestamp"
            case transactions = "transactions"
            case sharingKeys = "sharingKeys"
        }

                public let timestamp: Int

                public let transactions: [Transactions]

        public let sharingKeys: SyncSharingKeys?
    }

        public struct Transactions: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case action = "action"
            case identifier = "identifier"
            case time = "time"
            case type = "type"
            case content = "content"
        }

        public let action: SyncContentAction

                public let identifier: String

                public let time: Int

                public let type: String

                public let content: String?

        public init(action: SyncContentAction, identifier: String, time: Int, type: String, content: String? = nil) {
            self.action = action
            self.identifier = identifier
            self.time = time
            self.type = type
            self.content = content
        }
    }
}

extension UserDeviceAPIClient.Sync.UploadContent {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case timestamp = "timestamp"
            case summary = "summary"
        }

                public let timestamp: Int

        public let summary: [String: [String: Int]]

        public init(timestamp: Int, summary: [String: [String: Int]]) {
            self.timestamp = timestamp
            self.summary = summary
        }
    }
}
