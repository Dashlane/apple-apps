import Foundation

extension AnonymousEvent {

  public struct `LaunchPasswordChanger`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `bulkChangeCredentialCount`: Int? = nil, `domain`: Definition.Domain, `isBulkChange`: Bool,
      `isSuccess`: Bool, `lastRecipeStepPosition`: Int,
      `passwordChangerFailureReason`: Definition.PasswordChangerFailureReason? = nil,
      `passwordChangerRecipeVersion`: String? = nil
    ) {
      self.bulkChangeCredentialCount = bulkChangeCredentialCount
      self.domain = domain
      self.isBulkChange = isBulkChange
      self.isSuccess = isSuccess
      self.lastRecipeStepPosition = lastRecipeStepPosition
      self.passwordChangerFailureReason = passwordChangerFailureReason
      self.passwordChangerRecipeVersion = passwordChangerRecipeVersion
    }
    public let bulkChangeCredentialCount: Int?
    public let domain: Definition.Domain
    public let isBulkChange: Bool
    public let isSuccess: Bool
    public let lastRecipeStepPosition: Int
    public let name = "launch_password_changer"
    public let passwordChangerFailureReason: Definition.PasswordChangerFailureReason?
    public let passwordChangerRecipeVersion: String?
  }
}
