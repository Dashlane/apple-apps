import Foundation

extension UserEvent {

  public struct `CancelPlan`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `cancelPlanStep`: Definition.CancelPlanStep, `plan`: Definition.Plan,
      `planBillingPeriod`: Definition.PlanBillingPeriod,
      `surveyAnswer`: Definition.SurveyAnswer? = nil
    ) {
      self.cancelPlanStep = cancelPlanStep
      self.plan = plan
      self.planBillingPeriod = planBillingPeriod
      self.surveyAnswer = surveyAnswer
    }
    public let cancelPlanStep: Definition.CancelPlanStep
    public let name = "cancel_plan"
    public let plan: Definition.Plan
    public let planBillingPeriod: Definition.PlanBillingPeriod
    public let surveyAnswer: Definition.SurveyAnswer?
  }
}
