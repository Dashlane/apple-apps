import Foundation
extension UserDeviceAPIClient.Darkwebmonitoring {
        public struct DeregisterEmail: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring/DeregisterEmail"

        public let api: UserDeviceAPIClient

                public func callAsFunction(email: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(email: email)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deregisterEmail: DeregisterEmail {
        DeregisterEmail(api: api)
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.DeregisterEmail {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case email = "email"
        }

                public let email: String
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.DeregisterEmail {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case email = "email"
            case result = "result"
        }

                public let email: String

                public let result: String

        public init(email: String, result: String) {
            self.email = email
            self.result = result
        }
    }
}
