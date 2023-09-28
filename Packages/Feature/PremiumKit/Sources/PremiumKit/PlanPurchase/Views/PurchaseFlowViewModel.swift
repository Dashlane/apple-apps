#if canImport(UIKit)

import Combine
import DashTypes
import CorePremium
import SwiftUI
import UIKit

enum PurchaseFlowStep {
    case purchase(PurchaseViewModel, PlanPurchaseInitialViewRequest)
    case paywall(PaywallViewModel)
    case detail(PlanPurchaseViewModel, firstStep: Bool)
}

public enum PurchaseFlowDismissAction: Identifiable {
    case success(plan: PurchasePlan)
    case cancellation
    case failure(_ error: Error)

    public var id: String {
        switch self {
        case .success:
            return "success"
        case .cancellation:
            return "cancellation"
        case .failure:
            return "failure"
        }
    }
}

public class PurchaseFlowViewModel: ObservableObject {

    @Published
    var steps: [PurchaseFlowStep]

    @Published
    var alert: PurchaseFlowDismissAction?

    @Published
    var showPurchaseProcess: Bool = false

    var purchaseProcessViewModel: PurchaseProcessViewModel!

    private let dismissSubject: PassthroughSubject<PurchaseFlowDismissAction, Never> = .init()
    var dismissPublisher: AnyPublisher<PurchaseFlowDismissAction, Never> {
        dismissSubject.eraseToAnyPublisher()
    }

    let initialView: PlanPurchaseInitialViewRequest
    let planPurchaseServices: PlanPurchaseServicesContainer
    private let screenLocker: ScreenLocker?

    var startByList: Bool {
        switch initialView {
        case .list:
            return true
        default:
            return false
        }
    }

    public init(initialView: PlanPurchaseInitialViewRequest = .list,
                planPurchaseServices: PlanPurchaseServicesContainer) {
        self.steps = []
        self.initialView = initialView
        self.planPurchaseServices = planPurchaseServices
        self.screenLocker = planPurchaseServices.screenLocker
        self.steps.append(.purchase(makePurchaseView(), initialView))
    }

    func handlePurchaseViewAction<Content: View>(_ action: PurchaseView<Content>.Action) {
        switch action {
        case .cancel:
            dismissSubject.send(.cancellation)
        }
    }

    func handlePaywallViewAction(_ action: PaywallView.Action) {
        switch action {
        case .displayList:
            steps.append(.purchase(makePurchaseView(), .list))
        case .planDetails(let planTier):
            steps.append(.detail(makeDetailViewModel(planTier: planTier), firstStep: false))
        case .cancel:
            dismissSubject.send(.cancellation)
        }
    }

    func handlePurchasePlansListViewAction(_ action: PurchasePlansListView.Action) {
        switch action {
        case .planDetails(let planTier):
            steps.append(.detail(.init(planTier: planTier), firstStep: false))
        case .cancel:
            dismissSubject.send(.cancellation)
        }
    }

    func handlePlanPurchaseViewAction(_ action: PlanPurchaseView.Action) {
        func showPurchaseProcessView(for plan: PurchasePlan) {
            screenLocker?.pauseAutoLock()
            purchaseProcessViewModel = planPurchaseServices.makePurchaseProcessViewModel(with: plan)
            showPurchaseProcess = true
        }

        switch action {
        case .cancel:
            dismissSubject.send(.cancellation)
        case .buy(let plan):
            showPurchaseProcessView(for: plan)
        case .termsAndConditions:
            UIApplication.shared.open(DashlaneURLFactory.Endpoint.tos.url)
        case .policyPrivacy:
            UIApplication.shared.open(DashlaneURLFactory.Endpoint.privacySettings.url)
        }
    }

    func handlePurchaseProcessViewAction(_ action: PurchaseProcessView.Action) {
        switch action {
        case let .success(plan):
            purchaseProcessSuccess(plan: plan)
        case .cancellation:
            purchaseProcessCancellation()
        case .failure(let error):
            purchaseProcessFailure(error)
        }
    }

}

extension PurchaseFlowViewModel {

    private func makePurchaseView() -> PurchaseViewModel {
        return PurchaseViewModel(manager: DashlanePremiumManager.shared)
    }

    func makePaywallViewModel(key: CapabilityKey, purchasePlanGroup: PlanTier? = nil) -> PaywallViewModel? {
        return PaywallViewModel(key, purchasePlanGroup: purchasePlanGroup)
    }

    func makeListViewModel(planTiers: [PurchasePlan.Kind: PlanTier]) -> PlansListViewModel {
        return PlansListViewModel(
            activityReporter: planPurchaseServices.activityReporter,
            planTiers: planTiers.values.sorted(by: { $0.kind < $1.kind })
        )
    }

    func makeDetailViewModel(planTier: PlanTier) -> PlanPurchaseViewModel {
        return PlanPurchaseViewModel(planTier: planTier)
    }

}

private extension PurchaseFlowViewModel {

    func purchaseProcessSuccess(plan: PurchasePlan) {
        screenLocker?.resumeAutoLock()

        showPurchaseProcess = false
        self.alert = .success(plan: plan)
    }

    func purchaseProcessCancellation() {
        showPurchaseProcess = false
    }

    func purchaseProcessFailure(_ error: Error) {
        screenLocker?.resumeAutoLock()
        showPurchaseProcess = false

        guard (error as? TransactionError) != .paymentCancelled else { return }
        alert = .failure(error)
    }

}
#endif
