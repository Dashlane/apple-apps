import Foundation
extension AppAPIClient.Authentication {
        public struct GetTokens {
        public static let endpoint: Endpoint = "/authentication/GetTokens"

        public let api: AppAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.get(Self.endpoint, timeout: timeout)
        }
    }

        public var getTokens: GetTokens {
        GetTokens(api: api)
    }
}

extension AppAPIClient.Authentication.GetTokens {
        struct Body: Encodable {
    }
}

extension AppAPIClient.Authentication.GetTokens {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let tokens: [Tokens]

                public struct Tokens: Codable, Equatable {

                        public let login: String

                        public let token: String

            public init(login: String, token: String) {
                self.login = login
                self.token = token
            }
        }

        public init(tokens: [Tokens]) {
            self.tokens = tokens
        }
    }
}
