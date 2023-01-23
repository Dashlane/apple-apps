import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct DeactivateWebAuthnAuthenticator {
        public static let endpoint: Endpoint = "/authentication/DeactivateWebAuthnAuthenticator"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(credentialId: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(credentialId: credentialId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivateWebAuthnAuthenticator: DeactivateWebAuthnAuthenticator {
        DeactivateWebAuthnAuthenticator(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateWebAuthnAuthenticator {
        struct Body: Encodable {

                public let credentialId: String
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateWebAuthnAuthenticator {
    public typealias Response = Empty?
}
