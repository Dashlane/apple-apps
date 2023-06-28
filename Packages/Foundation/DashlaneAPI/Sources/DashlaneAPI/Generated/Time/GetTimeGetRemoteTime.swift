import Foundation
extension AppAPIClient.Time {
        public struct GetRemoteTime: APIRequest {
        public static let endpoint: Endpoint = "/time/GetRemoteTime"

        public let api: AppAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.get(Self.endpoint, timeout: timeout)
        }
    }

        public var getRemoteTime: GetRemoteTime {
        GetRemoteTime(api: api)
    }
}

extension AppAPIClient.Time.GetRemoteTime {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case tz = "tz"
        }

                public let tz: String?
    }
}

extension AppAPIClient.Time.GetRemoteTime {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case timestamp = "timestamp"
        }

                public let timestamp: Int

        public init(timestamp: Int) {
            self.timestamp = timestamp
        }
    }
}
