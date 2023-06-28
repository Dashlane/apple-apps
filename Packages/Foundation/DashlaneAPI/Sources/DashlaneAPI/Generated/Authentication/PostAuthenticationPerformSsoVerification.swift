import Foundation
extension AppAPIClient.Authentication {
        public struct PerformSsoVerification: APIRequest {
        public static let endpoint: Endpoint = "/authentication/PerformSsoVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, ssoToken: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, ssoToken: ssoToken)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performSsoVerification: PerformSsoVerification {
        PerformSsoVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformSsoVerification {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case ssoToken = "ssoToken"
        }

                public let login: String

                public let ssoToken: String
    }
}

extension AppAPIClient.Authentication.PerformSsoVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
