import Foundation
extension AppAPIClient.Analytics {
        public struct GetAnalyticsIds {
        public static let endpoint: Endpoint = "/analytics/GetAnalyticsIds"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAnalyticsIds: GetAnalyticsIds {
        GetAnalyticsIds(api: api)
    }
}

extension AppAPIClient.Analytics.GetAnalyticsIds {
        struct Body: Encodable {

                public let login: String
    }
}

extension AppAPIClient.Analytics.GetAnalyticsIds {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let devicesAnalyticsIds: [String]?

                public let userAnalyticsId: String?

        public init(devicesAnalyticsIds: [String]? = nil, userAnalyticsId: String? = nil) {
            self.devicesAnalyticsIds = devicesAnalyticsIds
            self.userAnalyticsId = userAnalyticsId
        }
    }
}
