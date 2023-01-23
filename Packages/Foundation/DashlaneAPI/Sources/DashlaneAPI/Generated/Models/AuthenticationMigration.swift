import Foundation

public enum AuthenticationMigration: String, Codable, Equatable, CaseIterable {
    case ssoMemberToAdmin = "sso_member_to_admin"
    case mpUserToSsoMember = "mp_user_to_sso_member"
    case ssoMemberToMpUser = "sso_member_to_mp_user"
}
