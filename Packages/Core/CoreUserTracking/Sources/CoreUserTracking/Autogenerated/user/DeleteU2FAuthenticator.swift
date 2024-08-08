import Foundation

extension UserEvent {

  public struct `DeleteU2FAuthenticator`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `errorName`: Definition.TwoFactorAuthenticationError? = nil, `flowStep`: Definition.FlowStep
    ) {
      self.errorName = errorName
      self.flowStep = flowStep
    }
    public let errorName: Definition.TwoFactorAuthenticationError?
    public let flowStep: Definition.FlowStep
    public let name = "delete_u2f_authenticator"
  }
}
