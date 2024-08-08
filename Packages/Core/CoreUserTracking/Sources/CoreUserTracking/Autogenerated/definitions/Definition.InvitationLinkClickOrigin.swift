import Foundation

extension Definition {

  public enum `InvitationLinkClickOrigin`: String, Encodable, Sendable {
    case `extensionMassDeployment` = "extension_mass_deployment"
    case `invitationEmail` = "invitation_email"
    case `sharedInvitationLink` = "shared_invitation_link"
  }
}
