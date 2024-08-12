#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CorePremium
  import StoreKit
  import Combine
  import CoreUserTracking
  import DashlaneAPI

  struct PlanPurchaseCTA {
    let duration: PaymentsAccessibleStoreOffersDuration
    let title: String
    let isLightColored: Bool
    let enabled: Bool?
  }

  struct PlanPurchaseViewModel {

    let planTier: PlanTier

    init(planTier: PlanTier) {
      self.planTier = planTier
    }

    var page: Page {
      switch planTier.kind {
      case .essentials, .advanced:
        return .availablePlansEssentialsDetails
      case .premium:
        return .availablePlansPremiumDetails
      case .family:
        return .availablePlansFamilyDetails
      default:
        return .availablePlans
      }
    }

    var ctas: [PlanPurchaseCTA] {
      planTier.plans.sorted { planA, _ in
        return planA.offer.duration == .monthly
      }.map { plan in
        let isYearly = plan.offer.duration == .yearly
        return PlanPurchaseCTA(
          duration: plan.offer.duration,
          title: ctaTitle(of: plan),
          isLightColored: isYearly,
          enabled: plan.offer.enabled
        )
      }
    }

    func ctaTitle(of plan: PurchasePlan) -> String {
      var price = "\(plan.localizedPrice) \(plan.periodDescription)"
      if let renewalPrice = ctaRenewalPrice(of: plan) {
        price += ", \(renewalPrice)"
      }
      return price
    }

    func ctaRenewalPrice(of plan: PurchasePlan) -> String? {
      guard plan.isDiscountedOffer || plan.isIntroductoryOffer else { return nil }
      guard !plan.isPeriodIdenticalToIntroductoryOfferPeriod else { return nil }

      return plan.renewalPriceDescription
    }
  }
#endif
