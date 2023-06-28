import Foundation

public struct AuthenticationGetMethodsChallenges: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case challenge = "challenge"
        case version = "version"
        case appId = "appId"
        case keyHandle = "keyHandle"
    }

    public let challenge: String

    public let version: String

    public let appId: String

    public let keyHandle: String

    public init(challenge: String, version: String, appId: String, keyHandle: String) {
        self.challenge = challenge
        self.version = version
        self.appId = appId
        self.keyHandle = keyHandle
    }
}
