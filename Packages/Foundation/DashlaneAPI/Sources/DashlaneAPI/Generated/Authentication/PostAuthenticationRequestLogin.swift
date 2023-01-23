import Foundation
extension AppAPIClient.Authentication {
        public struct RequestLogin {
        public static let endpoint: Endpoint = "/authentication/RequestLogin"

        public let api: AppAPIClient

                public func callAsFunction(login: String, deviceAccessKey: String, profiles: [AuthenticationProfiles]? = nil, u2fSecret: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, deviceAccessKey: deviceAccessKey, profiles: profiles, u2fSecret: u2fSecret)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestLogin: RequestLogin {
        RequestLogin(api: api)
    }
}

extension AppAPIClient.Authentication.RequestLogin {
        struct Body: Encodable {

                public let login: String

                public let deviceAccessKey: String

                public let profiles: [AuthenticationProfiles]?

                public let u2fSecret: String?
    }
}

extension AppAPIClient.Authentication.RequestLogin {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let profilesToDelete: [AuthenticationProfiles]

                public let verification: [Verification]

        public let ssoInfo: AuthenticationSsoInfo?

                public struct Verification: Codable, Equatable {

                        public enum `Type`: String, Codable, Equatable, CaseIterable {
                case duoPush = "duo_push"
                case sso = "sso"
                case totp = "totp"
                case u2f = "u2f"
            }

            public let type: `Type`

            public let challenges: [AuthenticationChallenges]?

                        public let ssoServiceProviderUrl: String?

            public init(type: `Type`, challenges: [AuthenticationChallenges]? = nil, ssoServiceProviderUrl: String? = nil) {
                self.type = type
                self.challenges = challenges
                self.ssoServiceProviderUrl = ssoServiceProviderUrl
            }
        }

        public init(profilesToDelete: [AuthenticationProfiles], verification: [Verification], ssoInfo: AuthenticationSsoInfo? = nil) {
            self.profilesToDelete = profilesToDelete
            self.verification = verification
            self.ssoInfo = ssoInfo
        }
    }
}
