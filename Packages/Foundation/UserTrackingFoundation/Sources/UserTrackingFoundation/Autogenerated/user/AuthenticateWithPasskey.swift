import Foundation

extension UserEvent {

  public struct `AuthenticateWithPasskey`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `passkeyAuthenticationErrorType`: Definition.PasskeyAuthenticationErrorType? = nil,
      `passkeyAuthenticationStatus`: Definition.CeremonyStatus,
      `passkeyType`: Definition.PasskeyType? = nil
    ) {
      self.passkeyAuthenticationErrorType = passkeyAuthenticationErrorType
      self.passkeyAuthenticationStatus = passkeyAuthenticationStatus
      self.passkeyType = passkeyType
    }
    public let name = "authenticate_with_passkey"
    public let passkeyAuthenticationErrorType: Definition.PasskeyAuthenticationErrorType?
    public let passkeyAuthenticationStatus: Definition.CeremonyStatus
    public let passkeyType: Definition.PasskeyType?
  }
}
