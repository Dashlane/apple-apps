#if canImport(UIKit)

import Foundation
import SwiftUI
import CorePremium
import StoreKit
import Combine
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization
import CoreUserTracking

struct PurchasePlansListView: View {

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
        .ds.background.alternate.opacity(0)
    ])

    @ViewBuilder
    var body: some View {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .navigationTitle(L10n.Core.plansActionBarTitle)
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .reportPageAppearance(.availablePlans)
    }

    private var plans: some View {
        ScrollView(.vertical) {
            VStack(spacing: 14) {
                ForEach(model.plans(for: model.selectedDuration)) { planRowViewModel in
                    PurchasePlanRowView(model: planRowViewModel)
                        .onTapWithFeedback {
                            select(plan: planRowViewModel.planTier)
                        }
                        .padding(.horizontal, 16)
                }
            }.padding(.top, 15)
        }
        .animation(.easeInOut, value: model.selectedDuration)
        .overlay(LinearGradient(gradient: overlayGradient, startPoint: .top, endPoint: .bottom)
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

struct PurchasePlansListView_Previews: PreviewProvider {
    static let esentialsPlan = PlanTier(kind: .advanced,
                                        plans: [
                                            PurchasePlan(storeKitProduct: SKProduct.makeMock(identifier: "", price: "1.99", priceLocale: Locale.current),
                                                                      offer: Offer(planName: "", duration: .monthly, enabled: true),
                                                                      kind: .advanced,
                                                                      capabilities: OfferCapabilitySet(),
                                                                      isCurrentSubscription: false),
                                            PurchasePlan(storeKitProduct: SKProduct.makeMock(identifier: "", price: "20", priceLocale: Locale.current),
                                                                     offer: Offer(planName: "", duration: .yearly, enabled: true),
                                                                     kind: .advanced,
                                                                     capabilities: OfferCapabilitySet(),
                                                                     isCurrentSubscription: false)
                                        ],
                                        capabilities: OfferCapabilitySet())

    static let premiumPlan = PlanTier(kind: .premium,
                                      plans: [
                                        PurchasePlan(storeKitProduct: SKProduct.makeMock(identifier: "", price: "4.99", priceLocale: Locale.current),
                                                                  offer: Offer(planName: "", duration: .monthly, enabled: true),
                                                                  kind: .premium,
                                                                  capabilities: OfferCapabilitySet(),
                                                                  isCurrentSubscription: true),
                                        PurchasePlan(storeKitProduct: SKProduct.makeMock(identifier: "", price: "42", priceLocale: Locale.current),
                                                                 offer: Offer(planName: "", duration: .yearly, enabled: true),
                                                                 kind: .premium,
                                                                 capabilities: OfferCapabilitySet(),
                                                                 isCurrentSubscription: false)
                                        ],
                                        capabilities: OfferCapabilitySet())

    static var previews: some View {
        MultiContextPreview {
            PurchasePlansListView(model: PlansListViewModel(activityReporter: .fake,
                                                            planTiers: [esentialsPlan, premiumPlan]), firstStep: false, action: { _ in })
                .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        }

    }
}
#endif
