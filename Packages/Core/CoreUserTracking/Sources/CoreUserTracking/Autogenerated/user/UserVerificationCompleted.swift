import Foundation

extension UserEvent {

  public struct `UserVerificationCompleted`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `attemptNum`: Int, `source`: Definition.AuthenticatorUserVerificationSource,
      `status`: Definition.CeremonyStatus, `verificationMethod`: Definition.Mode
    ) {
      self.attemptNum = attemptNum
      self.source = source
      self.status = status
      self.verificationMethod = verificationMethod
    }
    public let attemptNum: Int
    public let name = "user_verification_completed"
    public let source: Definition.AuthenticatorUserVerificationSource
    public let status: Definition.CeremonyStatus
    public let verificationMethod: Definition.Mode
  }
}
