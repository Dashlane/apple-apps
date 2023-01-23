import Foundation
extension AppAPIClient.Authentication {
        public struct PerformEmailTokenVerification {
        public static let endpoint: Endpoint = "/authentication/PerformEmailTokenVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, token: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, token: token)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performEmailTokenVerification: PerformEmailTokenVerification {
        PerformEmailTokenVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformEmailTokenVerification {
        struct Body: Encodable {

                public let login: String

                public let token: String
    }
}

extension AppAPIClient.Authentication.PerformEmailTokenVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
