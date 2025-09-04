import Foundation

extension UserEvent {

  public struct `AuthenticatorPushAction`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `authenticatorPushStatus`: Definition.AuthenticatorPushStatus,
      `authenticatorPushType`: Definition.AuthenticatorPushType
    ) {
      self.authenticatorPushStatus = authenticatorPushStatus
      self.authenticatorPushType = authenticatorPushType
    }
    public let authenticatorPushStatus: Definition.AuthenticatorPushStatus
    public let authenticatorPushType: Definition.AuthenticatorPushType
    public let name = "authenticator_push_action"
  }
}
