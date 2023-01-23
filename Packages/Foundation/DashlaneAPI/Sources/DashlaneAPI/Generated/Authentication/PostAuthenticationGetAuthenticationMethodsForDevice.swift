import Foundation
extension AppAPIClient.Authentication {
        public struct GetAuthenticationMethodsForDevice {
        public static let endpoint: Endpoint = "/authentication/GetAuthenticationMethodsForDevice"

        public let api: AppAPIClient

                public func callAsFunction(login: String, methods: [AuthenticationGetMethods], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, methods: methods)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAuthenticationMethodsForDevice: GetAuthenticationMethodsForDevice {
        GetAuthenticationMethodsForDevice(api: api)
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForDevice {
        struct Body: Encodable {

                public let login: String

                public let methods: [AuthenticationGetMethods]
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForDevice {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let verifications: [AuthenticationGetMethodsVerifications]

        public init(verifications: [AuthenticationGetMethodsVerifications]) {
            self.verifications = verifications
        }
    }
}
