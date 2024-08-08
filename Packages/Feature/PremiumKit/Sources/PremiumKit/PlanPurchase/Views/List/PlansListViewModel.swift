#if canImport(UIKit)

  import Foundation
  import CorePremium
  import Combine
  import CoreUserTracking

  class PlansListViewModel: ObservableObject {

    enum Mode {
      case monthlyAndYearlyPlans(monthly: [PurchasePlanRowModel], yearly: [PurchasePlanRowModel])
      case yearlyPlans([PurchasePlanRowModel])
    }

    @Published
    var selectedDuration: PlanDuration

    private let activityReporter: ActivityReporterProtocol
    let planTiers: [PlanTier]
    let mostDiscountedPlanGroup: PlanTier?

    let mode: Mode

    init(
      activityReporter: ActivityReporterProtocol,
      planTiers: [PlanTier]
    ) {
      self.activityReporter = activityReporter
      self.planTiers = planTiers

      self.mostDiscountedPlanGroup = planTiers.mostDiscountedPlanGroup()

      let monthlyRows: [PurchasePlanRowModel] = planTiers.compactMap { tier in
        guard let plan = tier.purchasePlan(for: .monthly) else {
          return nil
        }
        return PurchasePlanRowModel(planTier: tier, plan: plan)
      }

      let yearlyRows: [PurchasePlanRowModel] = planTiers.compactMap { tier in
        guard let plan = tier.purchasePlan(for: .yearly) else {
          return nil
        }
        return PurchasePlanRowModel(planTier: tier, plan: plan)
      }

      if monthlyRows.isEmpty {
        mode = .yearlyPlans(yearlyRows)
        selectedDuration = .yearly
      } else {
        mode = .monthlyAndYearlyPlans(monthly: monthlyRows, yearly: yearlyRows)
        selectedDuration = .monthly
      }

    }

    func plans(for duration: PlanDuration) -> [PurchasePlanRowModel] {
      switch mode {
      case let .monthlyAndYearlyPlans(monthly, yearly):
        return duration == .monthly ? monthly : yearly
      case let .yearlyPlans(yearly):
        return yearly
      }
    }

    func select(_ plan: PlanTier) {
      let planTiers = planTiers
      activityReporter.report(
        UserEvent.CallToAction(
          callToActionList: planTiers.compactMap { $0.userTrackingCallToAction },
          chosenAction: plan.userTrackingCallToAction, hasChosenNoAction: false))
    }

    func cancel() {
      let planTiers = planTiers
      activityReporter.report(
        UserEvent.CallToAction(
          callToActionList: planTiers.compactMap { $0.userTrackingCallToAction },
          hasChosenNoAction: true))
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
