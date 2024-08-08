import Foundation

extension UserEvent {

  public struct `UseAccountRecoveryKey`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `flowStep`: Definition.FlowStep, `useKeyErrorName`: Definition.UseKeyErrorName? = nil
    ) {
      self.flowStep = flowStep
      self.useKeyErrorName = useKeyErrorName
    }
    public let flowStep: Definition.FlowStep
    public let name = "use_account_recovery_key"
    public let useKeyErrorName: Definition.UseKeyErrorName?
  }
}
