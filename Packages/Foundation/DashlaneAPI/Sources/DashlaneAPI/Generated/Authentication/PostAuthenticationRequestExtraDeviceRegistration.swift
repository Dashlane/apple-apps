import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct RequestExtraDeviceRegistration {
        public static let endpoint: Endpoint = "/authentication/RequestExtraDeviceRegistration"

        public let api: UserDeviceAPIClient

                public func callAsFunction(tokenType: Empty?, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(tokenType: tokenType)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestExtraDeviceRegistration: RequestExtraDeviceRegistration {
        RequestExtraDeviceRegistration(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.RequestExtraDeviceRegistration {
        struct Body: Encodable {

        public let tokenType: Empty?
    }
}

extension UserDeviceAPIClient.Authentication.RequestExtraDeviceRegistration {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let token: String

        public init(token: String) {
            self.token = token
        }
    }
}
