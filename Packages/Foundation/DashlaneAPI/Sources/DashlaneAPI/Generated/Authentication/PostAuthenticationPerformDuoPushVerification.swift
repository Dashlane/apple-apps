import Foundation
extension AppAPIClient.Authentication {
        public struct PerformDuoPushVerification: APIRequest {
        public static let endpoint: Endpoint = "/authentication/PerformDuoPushVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performDuoPushVerification: PerformDuoPushVerification {
        PerformDuoPushVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformDuoPushVerification {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
        }

                public let login: String
    }
}

extension AppAPIClient.Authentication.PerformDuoPushVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
