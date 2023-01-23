import Foundation
extension AppAPIClient.AuthenticationQa {
        public struct GetDeviceRegistrationTokenForTestLogin {
        public static let endpoint: Endpoint = "/authentication-qa/GetDeviceRegistrationTokenForTestLogin"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getDeviceRegistrationTokenForTestLogin: GetDeviceRegistrationTokenForTestLogin {
        GetDeviceRegistrationTokenForTestLogin(api: api)
    }
}

extension AppAPIClient.AuthenticationQa.GetDeviceRegistrationTokenForTestLogin {
        struct Body: Encodable {

                public let login: String
    }
}

extension AppAPIClient.AuthenticationQa.GetDeviceRegistrationTokenForTestLogin {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let token: String

        public init(token: String) {
            self.token = token
        }
    }
}
