import Foundation

public enum AuthenticationCompleteWithAuthTicketType: String, Codable, Equatable, CaseIterable {
    case sso = "sso"
    case masterPassword = "master_password"
}
