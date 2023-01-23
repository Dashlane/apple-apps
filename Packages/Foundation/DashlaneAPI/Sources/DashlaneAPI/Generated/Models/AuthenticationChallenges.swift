import Foundation

public struct AuthenticationChallenges: Codable, Equatable {

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
