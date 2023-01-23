import Foundation

extension Definition {

public enum `PlanChangeStep`: String, Encodable {
case `changePlanCta` = "change_plan_cta"
case `confirmAndPayCta` = "confirm_and_pay_cta"
case `selectPlanTier` = "select_plan_tier"
}
}