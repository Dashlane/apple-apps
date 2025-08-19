import Foundation

extension UserEvent {

  public struct `RestartPlan`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`plan`: Definition.Plan, `planBillingPeriod`: Definition.PlanBillingPeriod) {
      self.plan = plan
      self.planBillingPeriod = planBillingPeriod
    }
    public let name = "restart_plan"
    public let plan: Definition.Plan
    public let planBillingPeriod: Definition.PlanBillingPeriod
  }
}
