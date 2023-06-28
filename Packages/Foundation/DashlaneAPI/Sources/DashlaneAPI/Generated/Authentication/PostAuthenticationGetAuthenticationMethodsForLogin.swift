import Foundation
extension AppAPIClient.Authentication {
        public struct GetAuthenticationMethodsForLogin: APIRequest {
        public static let endpoint: Endpoint = "/authentication/GetAuthenticationMethodsForLogin"

        public let api: AppAPIClient

                public func callAsFunction(login: String, deviceAccessKey: String, methods: [AuthenticationGetMethods], profiles: [AuthenticationGetMethodsForLoginProfiles]? = nil, u2fSecret: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, deviceAccessKey: deviceAccessKey, methods: methods, profiles: profiles, u2fSecret: u2fSecret)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAuthenticationMethodsForLogin: GetAuthenticationMethodsForLogin {
        GetAuthenticationMethodsForLogin(api: api)
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForLogin {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case deviceAccessKey = "deviceAccessKey"
            case methods = "methods"
            case profiles = "profiles"
            case u2fSecret = "u2fSecret"
        }

                public let login: String

                public let deviceAccessKey: String

                public let methods: [AuthenticationGetMethods]

                public let profiles: [AuthenticationGetMethodsForLoginProfiles]?

                public let u2fSecret: String?
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForLogin {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case verifications = "verifications"
            case accountType = "accountType"
            case profilesToDelete = "profilesToDelete"
        }

                public let verifications: [AuthenticationGetMethodsVerifications]

        public let accountType: AuthenticationGetMethodsAccountType

                public let profilesToDelete: [AuthenticationGetMethodsForLoginProfiles]?

        public init(verifications: [AuthenticationGetMethodsVerifications], accountType: AuthenticationGetMethodsAccountType, profilesToDelete: [AuthenticationGetMethodsForLoginProfiles]? = nil) {
            self.verifications = verifications
            self.accountType = accountType
            self.profilesToDelete = profilesToDelete
        }
    }
}
