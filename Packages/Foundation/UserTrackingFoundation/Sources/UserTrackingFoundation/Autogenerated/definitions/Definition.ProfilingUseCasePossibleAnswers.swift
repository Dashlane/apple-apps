import Foundation

extension Definition {

  public enum `ProfilingUseCasePossibleAnswers`: String, Encodable, Sendable {
    case `controlRevokedMembersPasswordAccess` = "control_revoked_members_password_access"
    case `membersUseStrongPasswords` = "members_use_strong_passwords"
    case `none`
    case `securelySharePasswords` = "securely_share_passwords"
    case `storePasswordsInOnePlace` = "store_passwords_in_one_place"
  }
}
