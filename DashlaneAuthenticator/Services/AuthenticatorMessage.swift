import Foundation

enum AuthenticatorMessage: Codable {
    case sync
}

public enum PasswordAppMessage: Codable {
    case login
    case logout
    case lockSettingsChanged
    case sync
    case refresh
}
