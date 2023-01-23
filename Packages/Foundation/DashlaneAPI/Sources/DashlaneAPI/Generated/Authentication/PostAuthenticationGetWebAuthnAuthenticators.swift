import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct GetWebAuthnAuthenticators {
        public static let endpoint: Endpoint = "/authentication/GetWebAuthnAuthenticators"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getWebAuthnAuthenticators: GetWebAuthnAuthenticators {
        GetWebAuthnAuthenticators(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.GetWebAuthnAuthenticators {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.GetWebAuthnAuthenticators {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let authenticators: [Authenticators]

                public struct Authenticators: Codable, Equatable {

                        public let name: String

                        public let credentialId: String

                        public let creationDateUnix: Int

                        public let isRoaming: Bool

            public init(name: String, credentialId: String, creationDateUnix: Int, isRoaming: Bool) {
                self.name = name
                self.credentialId = credentialId
                self.creationDateUnix = creationDateUnix
                self.isRoaming = isRoaming
            }
        }

        public init(authenticators: [Authenticators]) {
            self.authenticators = authenticators
        }
    }
}
