import Foundation

extension UserEvent {

  public struct `AdminChangeLoginEmail`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `changeLoginEmailFlowStep`: Definition.ChangeLoginEmailFlowStep,
      `errorName`: Definition.ChangeLoginError? = nil
    ) {
      self.changeLoginEmailFlowStep = changeLoginEmailFlowStep
      self.errorName = errorName
    }
    public let changeLoginEmailFlowStep: Definition.ChangeLoginEmailFlowStep
    public let errorName: Definition.ChangeLoginError?
    public let name = "admin_change_login_email"
  }
}
