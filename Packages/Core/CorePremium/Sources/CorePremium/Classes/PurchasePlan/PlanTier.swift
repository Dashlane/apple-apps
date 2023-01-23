import Foundation
import StoreKit

public struct PlanTier {
    public let kind: PurchasePlan.Kind
    public let plans: Array<PurchasePlan>
    public let capabilities: CapabilitySet

    public init(kind: PurchasePlan.Kind,
                plans: Array<PurchasePlan>,
                capabilities: CapabilitySet) {
        self.kind = kind
        self.plans = plans
        self.capabilities = capabilities
    }
}

extension PlanTier {
    public var monthlyPlan: PurchasePlan? {
        return plans.first(where: { plan in
            plan.offer.duration == .monthly
        })
    }
    public var yearlyPlan: PurchasePlan? {
        return plans.first(where: { plan in
            plan.offer.duration == .yearly
        })
    }
    
    public var yearlyDiscount: Float {
        guard let monthlyPlan = monthlyPlan, let yearlyPlan = yearlyPlan else {
            return 0
        }
        let monthlyPrice = monthlyPlan.price.floatValue
        let yearlyPrice = yearlyPlan.price.floatValue
        return (12 * monthlyPrice) - yearlyPrice
    }
}

extension PlanTier: Identifiable {
    public var id: PurchasePlan.Kind {
        return kind
    }
}

public extension Collection where Element == PlanTier {
    func mostDiscountedPlanGroup() -> PlanTier? {
        guard let plan = sorted(by: { $0.yearlyDiscount > $1.yearlyDiscount }).first,
              plan.yearlyDiscount > 0 else {
            return nil
        }
        return plan
    }
}

public extension PlanTier {
    func purchasePlan(for duration: PlanDuration) -> PurchasePlan? {
        switch duration {
            case .monthly:
                return monthlyPlan
            case .yearly:
                return yearlyPlan
        }
    }

    func discount(for duration: PlanDuration) -> Float? {
        switch duration {
            case .monthly:
                return nil
            case .yearly:
                return yearlyDiscount
        }
    }

    func localizedDiscount(for duration: PlanDuration) -> String? {
        switch duration {
            case .monthly:
                return nil
            case .yearly:
                return localizedYearlyDiscount
        }
    }
}
