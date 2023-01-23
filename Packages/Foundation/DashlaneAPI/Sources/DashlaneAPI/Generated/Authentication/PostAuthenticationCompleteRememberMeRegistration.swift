import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct CompleteRememberMeRegistration {
        public static let endpoint: Endpoint = "/authentication/CompleteRememberMeRegistration"

        public let api: UserDeviceAPIClient

                public func callAsFunction(masterPasswordEncryptionKey: String, authenticator: Authenticator, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(masterPasswordEncryptionKey: masterPasswordEncryptionKey, authenticator: authenticator)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeRememberMeRegistration: CompleteRememberMeRegistration {
        CompleteRememberMeRegistration(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.CompleteRememberMeRegistration {
        struct Body: Encodable {

                public let masterPasswordEncryptionKey: String

        public let authenticator: Authenticator
    }

        public struct Authenticator: Codable, Equatable {

                public enum AuthenticationType: String, Codable, Equatable, CaseIterable {
            case none = "none"
            case webauthnCreate = "webauthn.create"
            case webauthnGet = "webauthn.get"
        }

                public let authenticationType: AuthenticationType

        public let credential: Credential?

                public let isRoaming: Bool?

                public let name: String?

                public struct Credential: Codable, Equatable {

                        public enum `Type`: String, Codable, Equatable, CaseIterable {
                case publicKey = "public-key"
            }

                        public let id: String

                        public let rawId: String

            public let response: Response

                        public let type: `Type`

                        public struct Response: Codable, Equatable {

                                public let clientDataJSON: String

                                public let attestationObject: String?

                                public let authenticatorData: String?

                                public let signature: String?

                public init(clientDataJSON: String, attestationObject: String? = nil, authenticatorData: String? = nil, signature: String? = nil) {
                    self.clientDataJSON = clientDataJSON
                    self.attestationObject = attestationObject
                    self.authenticatorData = authenticatorData
                    self.signature = signature
                }
            }

            public init(id: String, rawId: String, response: Response, type: `Type`) {
                self.id = id
                self.rawId = rawId
                self.response = response
                self.type = type
            }
        }

        public init(authenticationType: AuthenticationType, credential: Credential? = nil, isRoaming: Bool? = nil, name: String? = nil) {
            self.authenticationType = authenticationType
            self.credential = credential
            self.isRoaming = isRoaming
            self.name = name
        }
    }
}

extension UserDeviceAPIClient.Authentication.CompleteRememberMeRegistration {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let sessionAccessKey: String

                public let sessionSecretKey: String

                public let sessionExpirationDateUnix: Int

        public init(sessionAccessKey: String, sessionSecretKey: String, sessionExpirationDateUnix: Int) {
            self.sessionAccessKey = sessionAccessKey
            self.sessionSecretKey = sessionSecretKey
            self.sessionExpirationDateUnix = sessionExpirationDateUnix
        }
    }
}
