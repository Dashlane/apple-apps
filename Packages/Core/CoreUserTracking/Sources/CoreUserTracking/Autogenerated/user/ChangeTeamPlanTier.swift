import Foundation

extension UserEvent {

  public struct `ChangeTeamPlanTier`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `currentBillingPlanTier`: Definition.B2BPlanTier, `currentPlanPaidSeatsCount`: Int,
      `hasPromo`: Bool? = nil, `nextBillingPlanTier`: Definition.B2BPlanTier,
      `planChangeStep`: Definition.PlanChangeStep, `seatAddedCount`: Int
    ) {
      self.currentBillingPlanTier = currentBillingPlanTier
      self.currentPlanPaidSeatsCount = currentPlanPaidSeatsCount
      self.hasPromo = hasPromo
      self.nextBillingPlanTier = nextBillingPlanTier
      self.planChangeStep = planChangeStep
      self.seatAddedCount = seatAddedCount
    }
    public let currentBillingPlanTier: Definition.B2BPlanTier
    public let currentPlanPaidSeatsCount: Int
    public let hasPromo: Bool?
    public let name = "change_team_plan_tier"
    public let nextBillingPlanTier: Definition.B2BPlanTier
    public let planChangeStep: Definition.PlanChangeStep
    public let seatAddedCount: Int
  }
}
