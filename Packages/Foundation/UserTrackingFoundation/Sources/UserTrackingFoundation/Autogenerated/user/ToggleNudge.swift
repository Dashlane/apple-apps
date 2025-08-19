import Foundation

extension UserEvent {

  public struct `ToggleNudge`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `integrationPlatform`: Definition.IntegrationPlatform, `nudgeState`: Definition.State,
      `nudgeType`: Definition.NudgeType
    ) {
      self.integrationPlatform = integrationPlatform
      self.nudgeState = nudgeState
      self.nudgeType = nudgeType
    }
    public let integrationPlatform: Definition.IntegrationPlatform
    public let name = "toggle_nudge"
    public let nudgeState: Definition.State
    public let nudgeType: Definition.NudgeType
  }
}
