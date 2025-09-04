import Foundation

extension UserEvent {

  public struct `ChangeMasterPassword`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `errorName`: Definition.ChangeMasterPasswordError? = nil, `flowStep`: Definition.FlowStep,
      `isLeaked`: Bool? = nil, `isWeak`: Bool? = nil
    ) {
      self.errorName = errorName
      self.flowStep = flowStep
      self.isLeaked = isLeaked
      self.isWeak = isWeak
    }
    public let errorName: Definition.ChangeMasterPasswordError?
    public let flowStep: Definition.FlowStep
    public let isLeaked: Bool?
    public let isWeak: Bool?
    public let name = "change_master_password"
  }
}
