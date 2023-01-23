#if canImport(UIKit)

import DesignSystem
import CorePremium
import SwiftUI
import UIDelight
import CoreLocalization

public struct PurchaseFlowView: View {

    @ObservedObject
    var model: PurchaseFlowViewModel

    let completion: (PurchaseFlowDismissAction) -> Void

    @Environment(\.dismiss)
    private var dismiss

    public init(model: PurchaseFlowViewModel,
                completion: @escaping (PurchaseFlowDismissAction) -> Void) {
        self.model = model
        self.completion = completion
    }

    public var body: some View {
        StepBasedContentNavigationView(steps: $model.steps) { step in
            content(for: step)
                .overlay {
                    if model.showPurchaseProcess {
                        PurchaseProcessView(viewModel: model.purchaseProcessViewModel, action: model.handlePurchaseProcessViewAction)
                    }
                }
                .animation(.easeInOut, value: model.showPurchaseProcess)
                .alert(item: $model.alert, content: alert(for:))
        }
        .accentColor(.ds.text.brand.standard)
        .onReceive(model.dismissPublisher) { action in
            switch action {
            case .cancellation:
                self.dismiss()
            default:
                break
            }
            self.completion(action)
        }
    }

    @ViewBuilder
    private func content(for step: PurchaseFlowStep) -> some View {
        switch step {
        case let .purchase(viewModel, initialRequest):
            PurchaseView(model: viewModel, action: model.handlePurchaseViewAction) { planTiers in
                makePurchaseView(for: initialRequest, planTiers: planTiers)
            }
        case let .paywall(viewModel):
            PaywallView(model: viewModel, shouldDisplayCloseButton: true, action: model.handlePaywallViewAction)
        case let .detail(viewModel, firstStep):
            PlanPurchaseView(model: viewModel, firstStep: firstStep, action: model.handlePlanPurchaseViewAction)
        }
    }

    private func alert(for dismissAction: PurchaseFlowDismissAction) -> Alert {
        Alert(title: Text(dismissAction.alertTitle),
              message: Text(dismissAction.alertMessage),
              dismissButton: .default(Text(L10n.Core.planScreensOK), action: { self.completion(dismissAction) }))
    }

    @ViewBuilder
    private func makePurchaseView(for request: PlanPurchaseInitialViewRequest, planTiers: [PurchasePlan.Kind: PlanTier]) -> some View {
        switch request {
        case .paywall(let key):
            if let viewModel = model.makePaywallViewModel(key: key, purchasePlanGroup: planTiers.firstPlan(for: key.orderedByPriorityPurchaseKinds)) {
                PaywallView(model: viewModel, shouldDisplayCloseButton: true, action: model.handlePaywallViewAction)
                .onAppear {
                    model.logPremium(key: key)
                }
            }
        case .list:
            purchasePlansListView(with: planTiers)
        case let .plan(kind):
            if let targetedPlanTier = planTiers.values.first(where: { $0.kind == kind }) {
                PlanPurchaseView(
                    model: model.makeDetailViewModel(planTier: targetedPlanTier),
                    firstStep: true,
                    action: model.handlePlanPurchaseViewAction
                )
            } else {
                purchasePlansListView(with: planTiers)
            }
        }
    }

    private func purchasePlansListView(with planTiers: [PurchasePlan.Kind: PlanTier]) -> some View {
        PurchasePlansListView(
            model: model.makeListViewModel(planTiers: planTiers),
            firstStep: model.startByList,
            action: model.handlePurchasePlansListViewAction
        )
        .onAppear {
            model.logPremium(type: .yearlyPlanDisplaySuccessful)
        }
    }
}

extension Dictionary where Key == PurchasePlan.Kind, Value == PlanTier {
    func firstPlan(for kinds: [PurchasePlan.Kind]) -> Value? {
        kinds.compactMap { self[$0] }.first
    }
}

fileprivate extension PurchaseFlowDismissAction {
    var alertTitle: String {
        switch self {
        case let .success(plan):
            return L10n.Core.planScreensPurchaseCompleteTitle(plan.localizedTitle)
        default:
            return L10n.Core.planScreensPurchaseErrorTitle
        }
    }

    var alertMessage: String {
        switch self {
        case .success:
            return L10n.Core.planScreensPurchaseCompleteMessage
        default:
            return L10n.Core.planScreensPurchaseErrorMessage
        }
    }
}
#endif
