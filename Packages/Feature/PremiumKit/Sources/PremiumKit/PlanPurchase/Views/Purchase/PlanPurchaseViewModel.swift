#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CorePremium
  import StoreKit
  import Combine
  import CoreUserTracking
  import CoreLocalization
  import DashlaneAPI

  struct PlanPurchaseCTA {
    let duration: PaymentsAccessibleStoreOffersDuration
    let title: String
    let isLightColored: Bool
    let enabled: Bool?
  }

  struct PlanPurchaseViewModel {

    enum PlanDisplay {
      case free
      case tier(PlanTier)
    }

    private let planDisplay: PlanDisplay

    init(planDisplay: PlanDisplay) {
      self.planDisplay = planDisplay
    }

    var kind: PurchasePlan.Kind? {
      switch planDisplay {
      case .free:
        .free
      case .tier(let planTier):
        planTier.kind
      }
    }

    var title: String {
      switch planDisplay {
      case .free:
        L10n.Core.plansFreeDescription
      case .tier(let planTier):
        planTier.localizedTitle
      }
    }

    var page: Page {
      guard case .tier(let planTier) = planDisplay else {
        return .availablePlans
      }
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

    var capabilities: PaymentsAccessibleStoreOffersCapabilities? {
      switch planDisplay {
      case .free:
        PaymentsAccessibleStoreOffersCapabilities(
          devicesLimit: CapabilitySchema(enabled: true, info: .init(limit: 1)),
          passwordsLimit: CapabilitySchema(enabled: true, info: .init(limit: 25)))
      case .tier(let planTier):
        planTier.capabilities
      }
    }

    var ctas: [PlanPurchaseCTA] {
      guard case .tier(let planTier) = planDisplay else {
        return []
      }

      return planTier.plans.sorted { planA, _ in
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

    func plan(for duration: PaymentsAccessibleStoreOffersDuration) -> PurchasePlan? {
      switch planDisplay {
      case .free:
        nil
      case .tier(let planTier):
        planTier.plans.first(where: { $0.offer.duration == duration })
      }
    }

    var displayFrozenMessage: Bool {
      switch planDisplay {
      case .free: return true
      case .tier: return false
      }
    }
  }
#endif
