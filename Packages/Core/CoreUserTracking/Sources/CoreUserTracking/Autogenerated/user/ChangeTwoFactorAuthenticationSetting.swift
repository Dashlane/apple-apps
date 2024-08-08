import Foundation

extension UserEvent {

  public struct `ChangeTwoFactorAuthenticationSetting`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `errorName`: Definition.TwoFactorAuthenticationError? = nil, `flowStep`: Definition.FlowStep,
      `flowType`: Definition.FlowType
    ) {
      self.errorName = errorName
      self.flowStep = flowStep
      self.flowType = flowType
    }
    public let errorName: Definition.TwoFactorAuthenticationError?
    public let flowStep: Definition.FlowStep
    public let flowType: Definition.FlowType
    public let name = "change_two_factor_authentication_setting"
  }
}
