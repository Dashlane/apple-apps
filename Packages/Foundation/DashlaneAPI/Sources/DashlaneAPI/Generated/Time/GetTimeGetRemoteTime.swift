import Foundation
extension AppAPIClient.Time {
        public struct GetRemoteTime {
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
        struct Body: Encodable {

                public let tz: String?
    }
}

extension AppAPIClient.Time.GetRemoteTime {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let timestamp: Int

        public init(timestamp: Int) {
            self.timestamp = timestamp
        }
    }
}
