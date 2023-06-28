import Foundation
extension AppAPIClient.Authentication {
        public struct GetAuthenticationMethodsForDevice: APIRequest {
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
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case methods = "methods"
        }

                public let login: String

                public let methods: [AuthenticationGetMethods]
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForDevice {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case verifications = "verifications"
            case accountType = "accountType"
        }

                public let verifications: [AuthenticationGetMethodsVerifications]

        public let accountType: AuthenticationGetMethodsAccountType

        public init(verifications: [AuthenticationGetMethodsVerifications], accountType: AuthenticationGetMethodsAccountType) {
            self.verifications = verifications
            self.accountType = accountType
        }
    }
}
