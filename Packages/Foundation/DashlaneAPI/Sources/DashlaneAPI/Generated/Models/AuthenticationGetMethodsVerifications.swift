import Foundation

public struct AuthenticationGetMethodsVerifications: Codable, Equatable {

    public let challenges: [AuthenticationChallenges]?

    public let ssoInfo: AuthenticationSsoInfo?

    public let type: AuthenticationType?

    public init(challenges: [AuthenticationChallenges]? = nil, ssoInfo: AuthenticationSsoInfo? = nil, type: AuthenticationType? = nil) {
        self.challenges = challenges
        self.ssoInfo = ssoInfo
        self.type = type
    }
}
