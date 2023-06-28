import Foundation

extension Definition {

public enum `InvitationLinkClickOrigin`: String, Encodable {
case `invitationEmail` = "invitation_email"
case `sharedInvitationLink` = "shared_invitation_link"
}
}