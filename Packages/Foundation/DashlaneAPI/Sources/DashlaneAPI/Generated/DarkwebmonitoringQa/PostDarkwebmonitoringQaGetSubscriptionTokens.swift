import Foundation
extension AppAPIClient.DarkwebmonitoringQa {
        public struct GetSubscriptionTokens: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring-qa/GetSubscriptionTokens"

        public let api: AppAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getSubscriptionTokens: GetSubscriptionTokens {
        GetSubscriptionTokens(api: api)
    }
}

extension AppAPIClient.DarkwebmonitoringQa.GetSubscriptionTokens {
        public struct Body: Encodable {
    }
}

extension AppAPIClient.DarkwebmonitoringQa.GetSubscriptionTokens {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case tokens = "tokens"
        }

                public let tokens: [Tokens]

                public struct Tokens: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case email = "email"
                case token = "token"
            }

                        public let email: String

                        public let token: String

            public init(email: String, token: String) {
                self.email = email
                self.token = token
            }
        }

        public init(tokens: [Tokens]) {
            self.tokens = tokens
        }
    }
}
