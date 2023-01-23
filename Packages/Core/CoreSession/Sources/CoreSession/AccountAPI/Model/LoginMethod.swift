import Foundation

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

public enum SSOMigrationType: String, Codable, Hashable {
    case ssoUserToMasterPasswordAdmin = "sso_member_to_admin"
    case ssoUserToMasterPasswordUser = "sso_member_to_mp_user"
    case masterPasswordUserToSSOUser = "mp_user_to_sso_member"
}
