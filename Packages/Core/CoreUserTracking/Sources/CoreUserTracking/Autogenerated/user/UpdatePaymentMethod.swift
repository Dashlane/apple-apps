import Foundation

extension UserEvent {

public struct `UpdatePaymentMethod`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`flowStep`: Definition.FlowStep, `plan`: Definition.Plan, `planBillingPeriod`: Definition.PlanBillingPeriod) {
self.flowStep = flowStep
self.plan = plan
self.planBillingPeriod = planBillingPeriod
}
public let flowStep: Definition.FlowStep
public let name = "update_payment_method"
public let plan: Definition.Plan
public let planBillingPeriod: Definition.PlanBillingPeriod
}
}
