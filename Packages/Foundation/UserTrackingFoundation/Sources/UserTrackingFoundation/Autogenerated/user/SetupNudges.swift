import Foundation

extension UserEvent {

  public struct `SetupNudges`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `action`: Definition.NudgeAction, `integrationPlatform`: Definition.IntegrationPlatform
    ) {
      self.action = action
      self.integrationPlatform = integrationPlatform
    }
    public let action: Definition.NudgeAction
    public let integrationPlatform: Definition.IntegrationPlatform
    public let name = "setup_nudges"
  }
}
