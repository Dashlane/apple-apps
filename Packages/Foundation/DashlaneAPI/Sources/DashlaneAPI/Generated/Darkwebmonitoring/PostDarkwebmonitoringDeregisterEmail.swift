import Foundation
extension UserDeviceAPIClient.Darkwebmonitoring {
        public struct DeregisterEmail {
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
        struct Body: Encodable {

                public let email: String
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.DeregisterEmail {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let email: String

                public let result: String

        public init(email: String, result: String) {
            self.email = email
            self.result = result
        }
    }
}
