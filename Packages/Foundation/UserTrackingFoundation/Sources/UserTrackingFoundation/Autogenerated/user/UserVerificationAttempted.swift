import Foundation

extension UserEvent {

  public struct `UserVerificationAttempted`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `attemptNum`: Int, `source`: Definition.AuthenticatorUserVerificationSource,
      `verificationMethod`: Definition.Mode
    ) {
      self.attemptNum = attemptNum
      self.source = source
      self.verificationMethod = verificationMethod
    }
    public let attemptNum: Int
    public let name = "user_verification_attempted"
    public let source: Definition.AuthenticatorUserVerificationSource
    public let verificationMethod: Definition.Mode
  }
}
