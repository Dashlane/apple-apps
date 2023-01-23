import Foundation

public enum AuthenticationGetMethods: String, Codable, Equatable, CaseIterable {
    case emailToken = "email_token"
    case totp = "totp"
    case duoPush = "duo_push"
    case dashlaneAuthenticator = "dashlane_authenticator"
    case u2f = "u2f"
}
