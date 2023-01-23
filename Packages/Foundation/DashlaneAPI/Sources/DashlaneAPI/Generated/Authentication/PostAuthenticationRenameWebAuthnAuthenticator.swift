import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct RenameWebAuthnAuthenticator {
        public static let endpoint: Endpoint = "/authentication/RenameWebAuthnAuthenticator"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(credentialId: String, name: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(credentialId: credentialId, name: name)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var renameWebAuthnAuthenticator: RenameWebAuthnAuthenticator {
        RenameWebAuthnAuthenticator(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.RenameWebAuthnAuthenticator {
        struct Body: Encodable {

                public let credentialId: String

                public let name: String
    }
}

extension UserDeviceAPIClient.Authentication.RenameWebAuthnAuthenticator {
    public typealias Response = Empty?
}
