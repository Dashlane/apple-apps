import Foundation
extension AppAPIClient.Authentication {
        public struct PerformExtraDeviceVerification {
        public static let endpoint: Endpoint = "/authentication/PerformExtraDeviceVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, token: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, token: token)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performExtraDeviceVerification: PerformExtraDeviceVerification {
        PerformExtraDeviceVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformExtraDeviceVerification {
        struct Body: Encodable {

                public let login: String

                public let token: String
    }
}

extension AppAPIClient.Authentication.PerformExtraDeviceVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
