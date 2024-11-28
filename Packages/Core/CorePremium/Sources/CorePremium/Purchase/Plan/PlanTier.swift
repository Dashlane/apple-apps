import DashlaneAPI
import Foundation

public enum PlanDuration: String, Decodable {
  case yearly
  case monthly
}

public struct PlanTier {
  public let plans: [PurchasePlan]
  public let capabilities: PaymentsAccessibleStoreOffersCapabilities

  public var kind: PurchasePlan.Kind? {
    return plans.first?.kind
  }

  public init(
    plans: [PurchasePlan],
    capabilities: PaymentsAccessibleStoreOffersCapabilities
  ) {
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

  public var yearlyDiscount: Decimal {
    guard let monthlyPlan = monthlyPlan, let yearlyPlan = yearlyPlan else {
      return 0
    }
    let monthlyPrice = monthlyPlan.price
    let yearlyPrice = yearlyPlan.price
    return (12 * monthlyPrice) - yearlyPrice
  }
}

extension Collection where Element == PlanTier {
  public func mostDiscountedPlanGroup() -> PlanTier? {
    guard let plan = sorted(by: { $0.yearlyDiscount > $1.yearlyDiscount }).first,
      plan.yearlyDiscount > 0
    else {
      return nil
    }
    return plan
  }
}

extension PlanTier {
  public func purchasePlan(for duration: PlanDuration) -> PurchasePlan? {
    switch duration {
    case .monthly:
      return monthlyPlan
    case .yearly:
      return yearlyPlan
    }
  }

  public func discount(for duration: PlanDuration) -> Decimal? {
    switch duration {
    case .monthly:
      return nil
    case .yearly:
      return yearlyDiscount
    }
  }

  public func localizedDiscount(for duration: PlanDuration) -> String? {
    switch duration {
    case .monthly:
      return nil
    case .yearly:
      return localizedYearlyDiscount
    }
  }
}
extension PlanTier {
  public var localizedYearlyDiscount: String {
    guard let plan = plans.first else {
      return ""
    }

    return plan.subscription.priceFormatStyle.format(yearlyDiscount)
  }
}
