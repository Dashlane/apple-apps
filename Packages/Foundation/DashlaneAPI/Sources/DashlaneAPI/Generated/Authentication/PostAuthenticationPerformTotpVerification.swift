import Foundation
extension AppAPIClient.Authentication {
        public struct PerformTotpVerification {
        public static let endpoint: Endpoint = "/authentication/PerformTotpVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, otp: String, activationFlow: Bool? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, otp: otp, activationFlow: activationFlow)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performTotpVerification: PerformTotpVerification {
        PerformTotpVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformTotpVerification {
        struct Body: Encodable {

                public let login: String

                public let otp: String

                public let activationFlow: Bool?
    }
}

extension AppAPIClient.Authentication.PerformTotpVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
