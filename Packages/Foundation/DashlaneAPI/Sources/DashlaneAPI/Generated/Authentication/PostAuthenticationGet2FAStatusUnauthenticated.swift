import Foundation
extension AppAPIClient.Authentication {
        public struct Get2FAStatusUnauthenticated {
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
        struct Body: Encodable {

                public let login: String
    }
}

extension AppAPIClient.Authentication.Get2FAStatusUnauthenticated {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let type: AuthenticationGet2FAStatusType

        public let ssoInfo: AuthenticationSsoInfo?

        public init(type: AuthenticationGet2FAStatusType, ssoInfo: AuthenticationSsoInfo? = nil) {
            self.type = type
            self.ssoInfo = ssoInfo
        }
    }
}
