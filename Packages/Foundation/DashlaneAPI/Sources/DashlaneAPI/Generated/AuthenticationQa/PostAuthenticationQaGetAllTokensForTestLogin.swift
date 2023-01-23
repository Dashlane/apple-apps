import Foundation
extension AppAPIClient.AuthenticationQa {
        public struct GetAllTokensForTestLogin {
        public static let endpoint: Endpoint = "/authentication-qa/GetAllTokensForTestLogin"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAllTokensForTestLogin: GetAllTokensForTestLogin {
        GetAllTokensForTestLogin(api: api)
    }
}

extension AppAPIClient.AuthenticationQa.GetAllTokensForTestLogin {
        struct Body: Encodable {

                public let login: String
    }
}

extension AppAPIClient.AuthenticationQa.GetAllTokensForTestLogin {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let teamInviteTokens: [TeamInviteTokens]

        public let teamFreeTrialTokens: [TeamFreeTrialTokens]

        public let resetToken: String?

        public let newDeviceToken: String?

        public let deleteToken: String?

        public let emailSubscriptionTokens: [EmailSubscriptionTokens]

                public struct TeamInviteTokens: Codable, Equatable {

            public let teamId: Int

            public let token: String

            public init(teamId: Int, token: String) {
                self.teamId = teamId
                self.token = token
            }
        }

                public struct TeamFreeTrialTokens: Codable, Equatable {

            public let token: String

            public init(token: String) {
                self.token = token
            }
        }

                public struct EmailSubscriptionTokens: Codable, Equatable {

            public let email: String

            public let token: String

            public init(email: String, token: String) {
                self.email = email
                self.token = token
            }
        }

        public init(teamInviteTokens: [TeamInviteTokens], teamFreeTrialTokens: [TeamFreeTrialTokens], resetToken: String?, newDeviceToken: String?, deleteToken: String?, emailSubscriptionTokens: [EmailSubscriptionTokens]) {
            self.teamInviteTokens = teamInviteTokens
            self.teamFreeTrialTokens = teamFreeTrialTokens
            self.resetToken = resetToken
            self.newDeviceToken = newDeviceToken
            self.deleteToken = deleteToken
            self.emailSubscriptionTokens = emailSubscriptionTokens
        }
    }
}
