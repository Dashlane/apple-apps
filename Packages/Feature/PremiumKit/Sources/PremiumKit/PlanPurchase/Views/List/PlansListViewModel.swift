#if canImport(UIKit)

import Foundation
import CorePremium
import Combine
import CoreUserTracking

class PlansListViewModel: ObservableObject {
    @Published
    var selectedDuration: PlanDuration = .monthly

    private let activityReporter: ActivityReporterProtocol
    let planTiers: [PlanTier]
    let mostDiscountedPlanGroup: PlanTier?

    private let monthlyRows: [PurchasePlanRowModel]
    private let yearlyRows: [PurchasePlanRowModel]

    init(activityReporter: ActivityReporterProtocol,
         planTiers: [PlanTier]) {
        self.activityReporter = activityReporter
        self.planTiers = planTiers

        self.mostDiscountedPlanGroup = planTiers.mostDiscountedPlanGroup()

        self.monthlyRows = planTiers.compactMap { tier in
            guard let plan = tier.purchasePlan(for: .monthly) else {
                return nil
            }
            return PurchasePlanRowModel(planTier: tier, plan: plan)
        }

        self.yearlyRows = planTiers.compactMap { tier in
            guard let plan = tier.purchasePlan(for: .yearly) else {
                return nil
            }
            return PurchasePlanRowModel(planTier: tier, plan: plan)
        }
    }

    func plans(for duration: PlanDuration) -> [PurchasePlanRowModel] {
        switch duration {
        case .yearly:
            return self.yearlyRows
        case .monthly:
            return self.monthlyRows
        }
    }

    func select(_ plan: PlanTier) {
        let planTiers = planTiers
        activityReporter.report(UserEvent.CallToAction(callToActionList: planTiers.compactMap { $0.userTrackingCallToAction }, chosenAction: plan.userTrackingCallToAction, hasChosenNoAction: false))
    }

    func cancel() {
        let planTiers = planTiers
        activityReporter.report(UserEvent.CallToAction(callToActionList: planTiers.compactMap { $0.userTrackingCallToAction }, hasChosenNoAction: true))
    }
}

extension PlanTier {
    var userTrackingCallToAction: Definition.CallToAction? {
        switch kind {
        case .essentials, .advanced:
                        return .essentialOffer
        case .family:
            return .familyOffer
        case .premium:
            return .premiumOffer
        default:
            return nil
        }
    }
}
#endif
