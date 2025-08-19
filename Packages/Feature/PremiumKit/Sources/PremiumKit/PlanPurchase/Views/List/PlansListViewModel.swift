import Combine
import CorePremium
import CoreTypes
import DashlaneAPI
import Foundation
import UserTrackingFoundation

class PlansListViewModel: ObservableObject {

  enum Mode {
    case monthlyAndYearlyPlans(monthly: [PurchasePlanRowModel], yearly: [PurchasePlanRowModel])
    case yearlyPlans([PurchasePlanRowModel])
  }

  @Published
  var selectedDuration: PlanDuration

  @Published
  var plans: [PurchasePlanRowModel] = []

  private let activityReporter: ActivityReporterProtocol
  private let vaultStateService: VaultStateServiceProtocol?
  let allPlanTiers: [PlanTier]
  let mostDiscountedPlanGroup: PlanTier?
  let mode: Mode

  init(
    activityReporter: ActivityReporterProtocol,
    vaultStateService: VaultStateServiceProtocol?,
    allPlanTiers: [PlanTier]
  ) {
    self.activityReporter = activityReporter
    self.vaultStateService = vaultStateService
    self.allPlanTiers = allPlanTiers
    self.mostDiscountedPlanGroup = allPlanTiers.mostDiscountedPlanGroup()

    let monthlyRows: [PurchasePlanRowModel] = allPlanTiers.compactMap { tier in
      tier.purchasePlan(for: .monthly).map { plan in
        PurchasePlanRowModel(planTier: tier, plan: plan, vaultStateService: vaultStateService)
      }
    }

    let yearlyRows: [PurchasePlanRowModel] = allPlanTiers.compactMap { tier in
      tier.purchasePlan(for: .yearly).map { plan in
        PurchasePlanRowModel(planTier: tier, plan: plan, vaultStateService: vaultStateService)
      }
    }

    if monthlyRows.isEmpty {
      mode = .yearlyPlans(yearlyRows)
      selectedDuration = .yearly
    } else {
      mode = .monthlyAndYearlyPlans(monthly: monthlyRows, yearly: yearlyRows)
      selectedDuration = .monthly
    }

    $selectedDuration
      .combineLatest(
        vaultStateService?.vaultStatePublisher() ?? Just(VaultState.default).eraseToAnyPublisher()
      )
      .map { [weak self] duration, vaultState in
        guard let self = self else { return [] }

        var plans = [PurchasePlanRowModel]()

        if vaultState == .frozen {
          plans.append(free)
        }

        switch mode {
        case let .monthlyAndYearlyPlans(monthly, yearly):
          plans.append(contentsOf: duration == .monthly ? monthly : yearly)
        case let .yearlyPlans(yearly):
          plans.append(contentsOf: yearly)
        }

        return plans
      }
      .assign(to: &$plans)
  }

  func select(_ plan: PlanTier) {
    let planTiers = allPlanTiers
    activityReporter.report(
      UserEvent.CallToAction(
        callToActionList: planTiers.compactMap { $0.userTrackingCallToAction },
        chosenAction: plan.userTrackingCallToAction, hasChosenNoAction: false))
  }

  func cancel() {
    let planTiers = allPlanTiers
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

extension PlansListViewModel {
  var free: PurchasePlanRowModel {
    let capabilities = PaymentsAccessibleStoreOffersCapabilities()
    let plan = PurchasePlan(
      subscription: .init(id: "free", price: 0, purchaseAction: { _ in .userCancelled }),
      offer: PaymentsAccessibleStoreOffers(
        planName: "Free",
        duration: .monthly,
        enabled: true
      ),
      kind: .free,
      capabilities: capabilities,
      isCurrentSubscription: false
    )
    let planTier = PlanTier(
      plans: [plan],
      capabilities: capabilities
    )

    return PurchasePlanRowModel(
      planTier: planTier, plan: plan, vaultStateService: vaultStateService)
  }
}
