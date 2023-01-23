import Foundation

enum AutheticatorMessage: Codable {
    case sync
}

public enum PasswordAppMessage: Codable {
    case login
    case logout
    case lockSettingsChanged
    case sync
    case refresh
}
