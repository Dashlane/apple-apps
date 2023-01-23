import Foundation
extension AppAPIClient.Authentication {
        public struct GetAuthenticationMethodsForLogin {
        public static let endpoint: Endpoint = "/authentication/GetAuthenticationMethodsForLogin"

        public let api: AppAPIClient

                public func callAsFunction(login: String, deviceAccessKey: String, methods: [AuthenticationGetMethods], profiles: [AuthenticationProfiles]? = nil, u2fSecret: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, deviceAccessKey: deviceAccessKey, methods: methods, profiles: profiles, u2fSecret: u2fSecret)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAuthenticationMethodsForLogin: GetAuthenticationMethodsForLogin {
        GetAuthenticationMethodsForLogin(api: api)
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForLogin {
        struct Body: Encodable {

                public let login: String

                public let deviceAccessKey: String

                public let methods: [AuthenticationGetMethods]

                public let profiles: [AuthenticationProfiles]?

                public let u2fSecret: String?
    }
}

extension AppAPIClient.Authentication.GetAuthenticationMethodsForLogin {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let verifications: [AuthenticationGetMethodsVerifications]

                public let profilesToDelete: [AuthenticationProfiles]?

        public init(verifications: [AuthenticationGetMethodsVerifications], profilesToDelete: [AuthenticationProfiles]? = nil) {
            self.verifications = verifications
            self.profilesToDelete = profilesToDelete
        }
    }
}
