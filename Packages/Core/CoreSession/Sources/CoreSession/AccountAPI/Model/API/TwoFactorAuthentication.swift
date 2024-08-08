import Foundation

public enum Login2FAOption: String, Codable {
  case token = "email_token"
  case totp
  case duoPush = "duo_push"
  case authenticator = "dashlane_authenticator"
}
