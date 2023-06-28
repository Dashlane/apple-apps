import Foundation

public enum AuthenticationGetMethodsType: String, Codable, Equatable, CaseIterable {
    case dashlaneAuthenticator = "dashlane_authenticator"
    case duoPush = "duo_push"
    case emailToken = "email_token"
    case sso = "sso"
    case totp = "totp"
    case u2f = "u2f"
}
