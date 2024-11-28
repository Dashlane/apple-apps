#if canImport(UIKit)

  import DesignSystem
  import CorePremium
  import SwiftUI
  import UIDelight
  import CoreLocalization
  import SwiftTreats
  import DashTypes

  public struct PurchaseFlowView: View {

    @ObservedObject
    var model: PurchaseFlowViewModel

    let completion: (PurchaseFlowDismissAction) -> Void

    @Environment(\.dismiss)
    private var dismiss

    public init(
      model: PurchaseFlowViewModel,
      completion: @escaping (PurchaseFlowDismissAction) -> Void
    ) {
      self.model = model
      self.completion = completion
    }

    public var body: some View {
      StepBasedContentNavigationView(steps: $model.steps) { step in
        content(for: step)
          .overlay {
            if model.showPurchaseProcess {
              PurchaseProcessView(
                viewModel: model.purchaseProcessViewModel,
                action: model.handlePurchaseProcessViewAction)
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
      case let .purchase(initialRequest):
        PurchaseView(model: model.makePurchaseViewModel(), action: model.handlePurchaseViewAction) {
          planTiers in
          makePurchaseView(for: initialRequest, planTiers: planTiers)
        }
      case let .detail(planTier, firstStep):
        PlanPurchaseView(
          model: model.makeDetailViewModel(
            planDisplay: planTier.kind == .free ? .free : .tier(planTier)), firstStep: firstStep,
          action: model.handlePlanPurchaseViewAction)
      }
    }

    private func alert(for dismissAction: PurchaseFlowDismissAction) -> Alert {
      Alert(
        title: Text(dismissAction.alertTitle),
        message: Text(dismissAction.alertMessage),
        dismissButton: .default(
          Text(L10n.Core.planScreensOK), action: { self.completion(dismissAction) }))
    }

    @ViewBuilder
    private func makePurchaseView(
      for request: PlanPurchaseInitialViewRequest, planTiers: [PurchasePlan.Kind: PlanTier]
    ) -> some View {
      switch request {
      case .paywall(let trigger):
        if let viewModel = model.makePaywallViewModel(
          trigger: trigger,
          purchasePlanGroup: planTiers.firstPlan(for: trigger.orderedByPriorityPurchaseKinds))
        {
          PaywallView(
            model: viewModel, shouldDisplayCloseButton: true, action: model.handlePaywallViewAction)
        } else {
        }

      case .list:
        purchasePlansListView(with: planTiers)
      case let .plan(kind):
        if kind == .free {
          PlanPurchaseView(
            model: model.makeDetailViewModel(planDisplay: .free),
            firstStep: true,
            action: model.handlePlanPurchaseViewAction
          )
        } else if let targetedPlanTier = planTiers.values.first(where: { $0.kind == kind }) {
          PlanPurchaseView(
            model: model.makeDetailViewModel(planDisplay: .tier(targetedPlanTier)),
            firstStep: true,
            action: model.handlePlanPurchaseViewAction
          )
        } else {
          purchasePlansListView(with: planTiers)
        }
      }
    }

    private func purchasePlansListView(with planTiers: [PurchasePlan.Kind: PlanTier]) -> some View {
      PlansListView(
        model: model.makeListViewModel(planTiers: planTiers),
        firstStep: model.startByList,
        action: model.handlePurchasePlansListViewAction
      )
    }
  }

  extension Dictionary where Key == PurchasePlan.Kind, Value == PlanTier {
    func firstPlan(for kinds: [PurchasePlan.Kind]) -> Value? {
      kinds.compactMap { self[$0] }.first
    }
  }

  extension PurchaseFlowDismissAction {
    fileprivate var alertTitle: String {
      switch self {
      case let .success(plan):
        return L10n.Core.planScreensPurchaseCompleteTitle(plan.localizedTitle)
      default:
        return L10n.Core.planScreensPurchaseErrorTitle
      }
    }

    fileprivate var alertMessage: String {
      switch self {
      case .success:
        return L10n.Core.planScreensPurchaseCompleteMessage
      case let .failure(error):
        return DiagnosticMode.isEnabled
          ? error.debugDescription : L10n.Core.planScreensPurchaseErrorMessage
      default:
        return L10n.Core.planScreensPurchaseErrorMessage
      }
    }
  }
#endif
