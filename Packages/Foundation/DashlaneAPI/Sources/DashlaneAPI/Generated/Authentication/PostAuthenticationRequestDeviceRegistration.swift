import Foundation
extension AppAPIClient.Authentication {
        public struct RequestDeviceRegistration {
        public static let endpoint: Endpoint = "/authentication/RequestDeviceRegistration"

        public let api: AppAPIClient

                public func callAsFunction(login: String, hasDashlaneAuthenticatorSupport: Bool? = nil, pushNotificationId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, hasDashlaneAuthenticatorSupport: hasDashlaneAuthenticatorSupport, pushNotificationId: pushNotificationId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestDeviceRegistration: RequestDeviceRegistration {
        RequestDeviceRegistration(api: api)
    }
}

extension AppAPIClient.Authentication.RequestDeviceRegistration {
        struct Body: Encodable {

                public let login: String

                public let hasDashlaneAuthenticatorSupport: Bool?

                public let pushNotificationId: String?
    }
}

extension AppAPIClient.Authentication.RequestDeviceRegistration {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let verification: [Verification]

        public let ssoInfo: AuthenticationSsoInfo?

                public struct Verification: Codable, Equatable {

            public let type: AuthenticationType

            public let challenges: [AuthenticationChallenges]?

                        public let ssoServiceProviderUrl: String?

            public init(type: AuthenticationType, challenges: [AuthenticationChallenges]? = nil, ssoServiceProviderUrl: String? = nil) {
                self.type = type
                self.challenges = challenges
                self.ssoServiceProviderUrl = ssoServiceProviderUrl
            }
        }

        public init(verification: [Verification], ssoInfo: AuthenticationSsoInfo? = nil) {
            self.verification = verification
            self.ssoInfo = ssoInfo
        }
    }
}
