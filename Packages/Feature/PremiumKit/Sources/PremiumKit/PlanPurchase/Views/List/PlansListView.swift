import Combine
import CoreFeature
import CoreLocalization
import CorePremium
import CoreUserTracking
import DashlaneAPI
import DesignSystem
import Foundation
import StoreKit
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

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
    .navigationTitle(CoreL10n.plansActionBarTitle)
    .background(Color.ds.background.default)
    .reportPageAppearance(.availablePlans)
  }

  private var monthlyAndYearlyPlans: some View {
    VStack(alignment: .leading) {
      Picker(selection: $model.selectedDuration, label: Text("")) {
        Text(CoreL10n.plansPeriodicityToggleMonthly)
          .tag(PlanDuration.monthly)

        Text(CoreL10n.plansPeriodicityToggleYearly)
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
      Button(CoreL10n.cancel) {
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

#Preview {
  let essentialsPlan = PlanTier(
    plans: [
      PurchasePlan(
        subscription: .init(id: "id1", price: 1, purchaseAction: { _ in fatalError() }),
        offer: PaymentsAccessibleStoreOffers(planName: "", duration: .monthly, enabled: true),
        kind: .essentials,
        capabilities: PaymentsAccessibleStoreOffersCapabilities(),
        isCurrentSubscription: true
      )
    ],
    capabilities: PaymentsAccessibleStoreOffersCapabilities()
  )

  let premiumPlan = PlanTier(
    plans: [
      PurchasePlan(
        subscription: .init(id: "id1", price: 4.99, purchaseAction: { _ in fatalError() }),
        offer: PaymentsAccessibleStoreOffers(planName: "", duration: .monthly, enabled: true),
        kind: .premium,
        capabilities: PaymentsAccessibleStoreOffersCapabilities(),
        isCurrentSubscription: true
      ),
      PurchasePlan(
        subscription: .init(id: "id2", price: 42, purchaseAction: { _ in fatalError() }),
        offer: PaymentsAccessibleStoreOffers(planName: "", duration: .yearly, enabled: true),
        kind: .premium,
        capabilities: PaymentsAccessibleStoreOffersCapabilities(),
        isCurrentSubscription: false
      ),
    ],
    capabilities: PaymentsAccessibleStoreOffersCapabilities()
  )

  return PlansListView(
    model: PlansListViewModel(
      activityReporter: .mock,
      vaultStateService: .mock(),
      allPlanTiers: [essentialsPlan, premiumPlan]
    ),
    firstStep: false,
    action: { _ in
    }
  )
  .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}
