import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct CompleteWebAuthnAuthenticatorRegistration {
        public static let endpoint: Endpoint = "/authentication/CompleteWebAuthnAuthenticatorRegistration"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(authenticator: Authenticator, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(authenticator: authenticator)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeWebAuthnAuthenticatorRegistration: CompleteWebAuthnAuthenticatorRegistration {
        CompleteWebAuthnAuthenticatorRegistration(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.CompleteWebAuthnAuthenticatorRegistration {
        struct Body: Encodable {

        public let authenticator: Authenticator
    }

        public struct Authenticator: Codable, Equatable {

                public enum AuthenticationType: String, Codable, Equatable, CaseIterable {
            case webauthnCreate = "webauthn.create"
        }

                public let authenticationType: AuthenticationType

                public let name: String

                public let isRoaming: Bool

        public let credential: Credential

                public struct Credential: Codable, Equatable {

                        public let id: String

                        public let rawId: String

            public let response: Response

                        public let type: String

                        public struct Response: Codable, Equatable {

                                public let attestationObject: String

                                public let clientDataJSON: String

                public init(attestationObject: String, clientDataJSON: String) {
                    self.attestationObject = attestationObject
                    self.clientDataJSON = clientDataJSON
                }
            }

            public init(id: String, rawId: String, response: Response, type: String) {
                self.id = id
                self.rawId = rawId
                self.response = response
                self.type = type
            }
        }

        public init(authenticationType: AuthenticationType, name: String, isRoaming: Bool, credential: Credential) {
            self.authenticationType = authenticationType
            self.name = name
            self.isRoaming = isRoaming
            self.credential = credential
        }
    }
}

extension UserDeviceAPIClient.Authentication.CompleteWebAuthnAuthenticatorRegistration {
    public typealias Response = Empty?
}
