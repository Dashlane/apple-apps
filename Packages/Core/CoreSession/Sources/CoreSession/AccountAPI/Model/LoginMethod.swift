import Foundation
import DashlaneAPI

public enum ThirdPartyOTPOption: String, Codable, Hashable {
    case totp
    case duoPush
    case authenticatorPush
}

public enum LoginMethod: Hashable {
        case tokenByEmail(_ u2fChallenges: [U2FChallenge] = [])
        case thirdPartyOTP(ThirdPartyOTPOption, u2fChallenges: [U2FChallenge] = [])
        case loginViaSSO(serviceProviderUrl: URL, isNitroProvider: Bool)
    case authenticator
}

public typealias SSOMigrationType = AuthenticationMigration
