import Foundation

extension UserEvent {

  public struct `ChangeContactEmail`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`flowStep`: Definition.FlowStep) {
      self.flowStep = flowStep
    }
    public let flowStep: Definition.FlowStep
    public let name = "change_contact_email"
  }
}
