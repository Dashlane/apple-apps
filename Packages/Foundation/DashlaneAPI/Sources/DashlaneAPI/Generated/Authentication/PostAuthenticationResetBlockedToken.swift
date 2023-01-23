import Foundation
extension AppAPIClient.Authentication {
        public struct ResetBlockedToken {
        public static let endpoint: Endpoint = "/authentication/ResetBlockedToken"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var resetBlockedToken: ResetBlockedToken {
        ResetBlockedToken(api: api)
    }
}

extension AppAPIClient.Authentication.ResetBlockedToken {
        struct Body: Encodable {

                public let login: String
    }
}

extension AppAPIClient.Authentication.ResetBlockedToken {
    public typealias Response = Empty?
}
