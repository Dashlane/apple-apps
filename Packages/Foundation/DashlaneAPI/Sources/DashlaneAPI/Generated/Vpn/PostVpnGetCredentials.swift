import Foundation
extension UserDeviceAPIClient.Vpn {
        public struct GetCredentials: APIRequest {
        public static let endpoint: Endpoint = "/vpn/GetCredentials"

        public let api: UserDeviceAPIClient

                public func callAsFunction(email: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(email: email)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getCredentials: GetCredentials {
        GetCredentials(api: api)
    }
}

extension UserDeviceAPIClient.Vpn.GetCredentials {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case email = "email"
        }

                public let email: String
    }
}

extension UserDeviceAPIClient.Vpn.GetCredentials {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case password = "password"
        }

                public let password: String

        public init(password: String) {
            self.password = password
        }
    }
}
