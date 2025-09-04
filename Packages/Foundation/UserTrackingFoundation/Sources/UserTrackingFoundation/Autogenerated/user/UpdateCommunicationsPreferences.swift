import Foundation

extension UserEvent {

  public struct `UpdateCommunicationsPreferences`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`flowStep`: Definition.FlowStep, `isMarketingOptIn`: Bool) {
      self.flowStep = flowStep
      self.isMarketingOptIn = isMarketingOptIn
    }
    public let flowStep: Definition.FlowStep
    public let isMarketingOptIn: Bool
    public let name = "update_communications_preferences"
  }
}
