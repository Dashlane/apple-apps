import Foundation

extension UserEvent {

  public struct `RegisterPasskey`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `passkeyRegistrationErrorType`: Definition.PasskeyRegistrationErrorType? = nil,
      `passkeyRegistrationStatus`: Definition.CeremonyStatus,
      `passkeyType`: Definition.PasskeyType? = nil
    ) {
      self.passkeyRegistrationErrorType = passkeyRegistrationErrorType
      self.passkeyRegistrationStatus = passkeyRegistrationStatus
      self.passkeyType = passkeyType
    }
    public let name = "register_passkey"
    public let passkeyRegistrationErrorType: Definition.PasskeyRegistrationErrorType?
    public let passkeyRegistrationStatus: Definition.CeremonyStatus
    public let passkeyType: Definition.PasskeyType?
  }
}
