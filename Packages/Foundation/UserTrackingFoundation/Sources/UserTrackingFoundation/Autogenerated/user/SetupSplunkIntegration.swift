import Foundation

extension UserEvent {

  public struct `SetupSplunkIntegration`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`splunkSetupStep`: Definition.SplunkSetupStep) {
      self.splunkSetupStep = splunkSetupStep
    }
    public let name = "setup_splunk_integration"
    public let splunkSetupStep: Definition.SplunkSetupStep
  }
}
