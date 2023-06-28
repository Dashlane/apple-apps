import Foundation
extension AppAPIClient.Authentication {
        public struct RequestEmailTokenVerification: APIRequest {
        public static let endpoint: Endpoint = "/authentication/RequestEmailTokenVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, pushNotificationId: String? = nil, u2fSecret: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, pushNotificationId: pushNotificationId, u2fSecret: u2fSecret)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestEmailTokenVerification: RequestEmailTokenVerification {
        RequestEmailTokenVerification(api: api)
    }
}

extension AppAPIClient.Authentication.RequestEmailTokenVerification {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case pushNotificationId = "pushNotificationId"
            case u2fSecret = "u2fSecret"
        }

                public let login: String

                public let pushNotificationId: String?

                public let u2fSecret: String?
    }
}

extension AppAPIClient.Authentication.RequestEmailTokenVerification {
    public typealias Response = Empty?
}
