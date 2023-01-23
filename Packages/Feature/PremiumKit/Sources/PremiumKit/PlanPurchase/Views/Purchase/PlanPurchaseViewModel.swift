#if canImport(UIKit)
import Foundation
import SwiftUI
import CorePremium
import StoreKit
import Combine
import CoreUserTracking

struct PlanPurchaseCTA {
    let duration: PlanDuration
    let title: String
    let subtitle: String
    let renewalPrice: String?
    let isLightColored: Bool
    let enabled: Bool
}

class PlanPurchaseViewModel: ObservableObject {

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
        planTier.plans.map { plan in
            let isMonthly = plan.offer.duration == .monthly
            return PlanPurchaseCTA(
                duration: plan.offer.duration,
                title: ctaTitle(of: plan),
                subtitle: ctaSubtitle(of: plan),
                renewalPrice: ctaRenewalPrice(of: plan),
                isLightColored: isMonthly,
                enabled: plan.offer.enabled
            )
        }
    }

    func ctaTitle(of plan: PurchasePlan) -> String {
        return plan.localizedPrice
    }

    func ctaSubtitle(of plan: PurchasePlan) -> String {
        return plan.periodDescription
    }

    func ctaRenewalPrice(of plan: PurchasePlan) -> String? {
        guard plan.isDiscountedOffer || plan.isIntroductoryOffer else { return nil }
        guard !plan.isPeriodIdenticalToIntroductoryOfferPeriod else { return nil }

        return plan.renewalPriceDescription
    }
}
#endif
