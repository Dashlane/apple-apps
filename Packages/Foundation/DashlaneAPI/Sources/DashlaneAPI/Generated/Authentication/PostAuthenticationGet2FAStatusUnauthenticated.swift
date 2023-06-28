import Foundation
extension AppAPIClient.Authentication {
        public struct Get2FAStatusUnauthenticated: APIRequest {
        public static let endpoint: Endpoint = "/authentication/Get2FAStatusUnauthenticated"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var get2FAStatusUnauthenticated: Get2FAStatusUnauthenticated {
        Get2FAStatusUnauthenticated(api: api)
    }
}

extension AppAPIClient.Authentication.Get2FAStatusUnauthenticated {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
        }

                public let login: String
    }
}

extension AppAPIClient.Authentication.Get2FAStatusUnauthenticated {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case isDuoEnabled = "isDuoEnabled"
            case hasDashlaneAuthenticator = "hasDashlaneAuthenticator"
            case ssoInfo = "ssoInfo"
        }

        public let type: AuthenticationGet2FAStatusType

                public let isDuoEnabled: Bool

                public let hasDashlaneAuthenticator: Bool

        public let ssoInfo: AuthenticationSsoInfo?

        public init(type: AuthenticationGet2FAStatusType, isDuoEnabled: Bool, hasDashlaneAuthenticator: Bool, ssoInfo: AuthenticationSsoInfo? = nil) {
            self.type = type
            self.isDuoEnabled = isDuoEnabled
            self.hasDashlaneAuthenticator = hasDashlaneAuthenticator
            self.ssoInfo = ssoInfo
        }
    }
}
