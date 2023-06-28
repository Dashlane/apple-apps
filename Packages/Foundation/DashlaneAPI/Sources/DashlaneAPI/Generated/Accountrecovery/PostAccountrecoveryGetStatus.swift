import Foundation
extension AppAPIClient.Accountrecovery {
        public struct GetStatus: APIRequest {
        public static let endpoint: Endpoint = "/accountrecovery/GetStatus"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getStatus: GetStatus {
        GetStatus(api: api)
    }
}

extension AppAPIClient.Accountrecovery.GetStatus {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
        }

                public let login: String
    }
}

extension AppAPIClient.Accountrecovery.GetStatus {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case enabled = "enabled"
        }

                public let enabled: Bool

        public init(enabled: Bool) {
            self.enabled = enabled
        }
    }
}
