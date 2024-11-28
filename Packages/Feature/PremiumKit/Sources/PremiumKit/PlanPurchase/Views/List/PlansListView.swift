#if canImport(UIKit)

  import Foundation
  import SwiftUI
  import CorePremium
  import CoreFeature
  import StoreKit
  import Combine
  import UIDelight
  import UIComponents
  import DesignSystem
  import CoreLocalization
  import CoreUserTracking
  import DashlaneAPI

  struct PlansListView: View {

    enum Action {
      case cancel
      case planDetails(PlanTier)
    }

    @ObservedObject
    var model: PlansListViewModel
    let firstStep: Bool

    let action: (Action) -> Void

    private let overlayGradient = Gradient(colors: [
      .ds.background.alternate,
      .ds.background.alternate.opacity(0),
    ])

    @ViewBuilder
    var body: some View {
      Group {
        if model.mode.shouldShowPicker {
          monthlyAndYearlyPlans
        } else {
          plans
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          backButton
        }
      }
      .navigationTitle(L10n.Core.plansActionBarTitle)
      .background(Color.ds.background.default)
      .reportPageAppearance(.availablePlans)
    }

    private var monthlyAndYearlyPlans: some View {
      VStack(alignment: .leading) {
        Picker(selection: $model.selectedDuration, label: Text("")) {
          Text(L10n.Core.plansPeriodicityToggleMonthly)
            .tag(PlanDuration.monthly)

          Text(L10n.Core.plansPeriodicityToggleYearly)
            .tag(PlanDuration.yearly)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.top, 13)
        .padding(.horizontal, 16)
        plans
      }
    }

    private var plans: some View {
      ScrollView(.vertical) {
        VStack(spacing: 14) {
          ForEach(model.plans) { planRowViewModel in
            PurchasePlanRowView(model: planRowViewModel)
              .onTapWithFeedback {
                select(plan: planRowViewModel.planTier)
              }
              .padding(.horizontal, 16)
          }
        }.padding(.top, 15)
      }
      .animation(.easeInOut, value: model.selectedDuration)
      .overlay(
        LinearGradient(gradient: overlayGradient, startPoint: .top, endPoint: .bottom)
          .frame(height: 15),
        alignment: .top)
    }

    @ViewBuilder var backButton: some View {
      if firstStep {
        NavigationBarButton(L10n.Core.cancel) {
          cancel()
        }
      }
    }

    func cancel() {
      action(.cancel)
      model.cancel()
    }

    func select(plan: PlanTier) {
      action(.planDetails(plan))
      model.select(plan)
    }
  }

  extension PlansListViewModel.Mode {
    var shouldShowPicker: Bool {
      switch self {
      case .monthlyAndYearlyPlans:
        return true
      case .yearlyPlans:
        return false
      }
    }
  }

  struct PurchasePlansListView_Previews: PreviewProvider {
    static let essentialsPlan = PlanTier(
      plans: [
        PurchasePlan(
          subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .monthly, enabled: true),
          kind: .advanced,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(),
          isCurrentSubscription: false),
        PurchasePlan(
          subscription: .init(id: "id2", price: 20, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .yearly, enabled: true),
          kind: .advanced,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(),
          isCurrentSubscription: false),
      ],
      capabilities: PaymentsAccessibleStoreOffersCapabilities())

    static let premiumPlan = PlanTier(
      plans: [
        PurchasePlan(
          subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .monthly, enabled: true),
          kind: .premium,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(),
          isCurrentSubscription: true),
        PurchasePlan(
          subscription: .init(id: "id2", price: 42, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .yearly, enabled: true),
          kind: .premium,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(),
          isCurrentSubscription: false),
      ],
      capabilities: PaymentsAccessibleStoreOffersCapabilities())

    static var previews: some View {
      MultiContextPreview {
        PlansListView(
          model: PlansListViewModel(
            activityReporter: .mock,
            vaultStateService: .mock,
            allPlanTiers: [essentialsPlan, premiumPlan]), firstStep: false, action: { _ in }
        )
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      }

    }
  }
#endif
