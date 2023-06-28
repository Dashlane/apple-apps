import Foundation

public struct AuthenticationGetMethodsVerifications: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case challenges = "challenges"
        case ssoInfo = "ssoInfo"
        case type = "type"
    }

    public let challenges: [AuthenticationGetMethodsChallenges]?

    public let ssoInfo: AuthenticationSsoInfo?

    public let type: AuthenticationGetMethodsType?

    public init(challenges: [AuthenticationGetMethodsChallenges]? = nil, ssoInfo: AuthenticationSsoInfo? = nil, type: AuthenticationGetMethodsType? = nil) {
        self.challenges = challenges
        self.ssoInfo = ssoInfo
        self.type = type
    }
}
