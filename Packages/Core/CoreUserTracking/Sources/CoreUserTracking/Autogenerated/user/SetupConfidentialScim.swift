import Foundation

extension UserEvent {

  public struct `SetupConfidentialScim`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`scimSetupStep`: Definition.ScimSetupStep) {
      self.scimSetupStep = scimSetupStep
    }
    public let name = "setup_confidential_scim"
    public let scimSetupStep: Definition.ScimSetupStep
  }
}
