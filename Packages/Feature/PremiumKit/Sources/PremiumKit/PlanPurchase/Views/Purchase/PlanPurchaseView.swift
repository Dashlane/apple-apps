#if canImport(UIKit)


import Foundation
import SwiftUI
import CorePremium
import StoreKit
import Combine
import UIDelight
import UIComponents
import CoreLocalization
import DesignSystem

struct PlanPurchaseView: View {

    enum Action {
        case buy(PurchasePlan)
        case termsAndConditions
        case policyPrivacy
        case cancel
    }

    let model: PlanPurchaseViewModel
    let firstStep: Bool

    let action: (Action) -> Void

    @State private var showingTermsAndConfitionsSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(model.planTier.localizedTitle)
                    .font(DashlaneFont.custom(26, .medium).font)
                    .foregroundColor(.ds.text.brand.standard)

                capabilities
            }.padding(.leading, 33)

            CTAs

            termsAndConditionsPanel

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .reportPageAppearance(model.page)
    }

    @ViewBuilder
    var capabilities: some View {
        PlanCapabilitiesView(kind: model.planTier.kind,
                             set: model.planTier.capabilities)
    }

    @ViewBuilder
    var CTAs: some View {
        HStack(alignment: .top, spacing: 20) {
            Spacer()
            ForEach(model.ctas, id: \.title) { cta in
                VStack(alignment: .center) {
                    Button(action: { buy(duration: cta.duration) }, label: {
                        VStack {
                            Text(cta.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            Text(cta.subtitle)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(cta.isLightColored ? .ds.text.inverse.catchy : .ds.text.brand.standard)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(RoundedRectangle(cornerRadius: 5.0).foregroundColor(cta.isLightColored ? .ds.container.expressive.brand.catchy.idle : .ds.container.expressive.brand.quiet.active))
                    })
                    .disabled(!cta.enabled)
                    .opacity(cta.enabled ? 1 : 0.55)

                    if let renewalPriceDescription = cta.renewalPrice {
                        Text(renewalPriceDescription)
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundColor(.ds.text.neutral.standard)
                    }
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    var termsAndConditionsPanel: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(L10n.Core.plansCguAppleId2)
                    .font(.caption2)
                    .foregroundColor(.ds.text.neutral.standard)
                    .padding(.horizontal, 10)
                Text(L10n.Core.plansCguMore)
                    .font(.caption2)
                    .foregroundColor(.ds.text.neutral.standard)
                    .padding(.horizontal, 10)
                    .fiberAccessibilityAddTraits(.isButton)
            }
            Spacer()
        }
        .onTapGesture {
            self.showingTermsAndConfitionsSheet.toggle()
        }
        .actionSheet(isPresented: $showingTermsAndConfitionsSheet) {
            ActionSheet(title: Text(L10n.Core.kwCreateAccountTermsConditions),
                        buttons: [
                            .default(Text(L10n.Core.kwCreateAccountTermsConditions)) {
                                action(.termsAndConditions)
                            },
                            .default(Text(L10n.Core.kwCreateAccountPrivacy)) {
                                action(.policyPrivacy)
                            },
                            .cancel(Text(L10n.Core.cancel))
                        ])
        }
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 5.0).foregroundColor(.ds.background.alternate))
        .padding(10)
    }

    @ViewBuilder var backButton: some View {
        if firstStep {
            NavigationBarButton(action: { action(.cancel) }, title: L10n.Core.cancel)
        }
    }

    private func buy(duration: PlanDuration) {
        guard let plan = model.planTier.plans.first(where: {  $0.offer.duration == duration }) else {
            return
        }
        action(.buy(plan))
    }
}

struct PlanPurchaseView_Previews: PreviewProvider {
    static let capabilities = OfferCapabilitySet(creditMonitoring: .init(enabled: true, info: nil),
                                                 dataLeak: .init(enabled: true, info: nil),
                                                 secureWiFi: .init(enabled: true, info: nil))
    static let planGroup = PlanTier(kind: .premium,
                                    plans: [
                                        PurchasePlan(storeKitProduct: SKProduct.makeMock(identifier: "", price: "4.99", priceLocale: Locale.current),
                                                                  offer: Offer(planName: "", duration: .monthly, enabled: true),
                                                                  kind: .premium,
                                                                  capabilities: capabilities,
                                                                  isCurrentSubscription: true),
                                        PurchasePlan(storeKitProduct: SKProduct.makeMock(identifier: "", price: "42", priceLocale: Locale.current),
                                                                 offer: Offer(planName: "", duration: .yearly, enabled: true),
                                                                 kind: .premium,
                                                                 capabilities: capabilities,
                                                                 isCurrentSubscription: false)
                                    ],
                                    capabilities: capabilities)

    static var previews: some View {
        MultiContextPreview {
            PlanPurchaseView(model: PlanPurchaseViewModel(planTier: planGroup), firstStep: false) { _ in }
        }
    }
 }
#endif
