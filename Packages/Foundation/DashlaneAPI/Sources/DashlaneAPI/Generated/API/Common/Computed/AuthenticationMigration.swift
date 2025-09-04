import Foundation

public enum AuthenticationMigration: String, Sendable, Hashable, Codable, CaseIterable {
  case ssoMemberToAdmin = "sso_member_to_admin"
  case mpUserToSSOMember = "mp_user_to_sso_member"
  case ssoMemberToMpUser = "sso_member_to_mp_user"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
