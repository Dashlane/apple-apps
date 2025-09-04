import Foundation

extension Definition {

  public enum `DashboardAction`: String, Encodable, Sendable {
    case `copyInvite` = "copy_invite"
    case `removeMember` = "remove_member"
    case `resetInvite` = "reset_invite"
  }
}
