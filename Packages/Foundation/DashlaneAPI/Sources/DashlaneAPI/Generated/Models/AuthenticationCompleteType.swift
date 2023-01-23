import Foundation

public enum AuthenticationCompleteType: String, Codable, Equatable, CaseIterable {
    case sso = "sso"
    case masterPassword = "master_password"
}
