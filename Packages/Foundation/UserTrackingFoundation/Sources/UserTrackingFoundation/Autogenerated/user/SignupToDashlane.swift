import Foundation

extension UserEvent {

  public struct `SignupToDashlane`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `invitationLinkClickOrigin`: Definition.InvitationLinkClickOrigin,
      `signupFlowStep`: Definition.SignupFlowStep
    ) {
      self.invitationLinkClickOrigin = invitationLinkClickOrigin
      self.signupFlowStep = signupFlowStep
    }
    public let invitationLinkClickOrigin: Definition.InvitationLinkClickOrigin
    public let name = "signup_to_dashlane"
    public let signupFlowStep: Definition.SignupFlowStep
  }
}
