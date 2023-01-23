import Foundation

public enum Login2FA: String, Codable {
    case token = "email_token"
    case totp
    case duoPush = "duo_push"
    case sso
    case authenticator = "dashlane_authenticator"
}

public struct TwoFactorAuthenticationLogin: Decodable, Equatable {
    let type: Login2FA
    let challenges: [U2FChallenge]?
    let ssoInfo: SSOInfo?
    
    init(type: Login2FA, challenges: [U2FChallenge]?, ssoInfo: SSOInfo? = nil) {
        self.type = type
        self.challenges = challenges
        self.ssoInfo = ssoInfo
    }
}

public enum Login2FAOption: String, Codable {
    case token = "email_token"
    case totp
    case duoPush = "duo_push"
    case authenticator = "dashlane_authenticator"
}
