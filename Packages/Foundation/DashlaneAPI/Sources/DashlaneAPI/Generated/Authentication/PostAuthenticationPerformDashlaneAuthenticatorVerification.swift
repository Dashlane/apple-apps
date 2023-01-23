import Foundation
extension AppAPIClient.Authentication {
        public struct PerformDashlaneAuthenticatorVerification {
        public static let endpoint: Endpoint = "/authentication/PerformDashlaneAuthenticatorVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, deviceName: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, deviceName: deviceName)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performDashlaneAuthenticatorVerification: PerformDashlaneAuthenticatorVerification {
        PerformDashlaneAuthenticatorVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformDashlaneAuthenticatorVerification {
        struct Body: Encodable {

                public let login: String

                public let deviceName: String?
    }
}

extension AppAPIClient.Authentication.PerformDashlaneAuthenticatorVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
