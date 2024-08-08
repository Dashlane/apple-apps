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
  import DashlaneAPI

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

    var body: some View {
      VStack(alignment: .leading) {
        Text(model.planTier.localizedTitle)
          .textStyle(.title.section.medium)
          .foregroundColor(.ds.text.brand.standard)
          .padding(.vertical, 12)

        capabilities

        termsAndConditionsPanel

        CTAs

      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          backButton
        }
      }
      .padding(.horizontal)
      .backgroundColorIgnoringSafeArea(.ds.background.default)
      .reportPageAppearance(model.page)
    }

    @ViewBuilder
    var capabilities: some View {
      PlanCapabilitiesView(
        kind: model.planTier.kind,
        capabilities: model.planTier.capabilities)
    }

    @ViewBuilder
    var CTAs: some View {
      ForEach(model.ctas, id: \.title) { cta in
        Button(cta.title) {
          buy(duration: cta.duration)
        }
        .style(mood: .brand, intensity: cta.isLightColored ? .quiet : .catchy)
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(cta.enabled == false)
      }
    }

    @ViewBuilder
    var termsAndConditionsPanel: some View {
      Text(L10n.Core.plansCguAppleId2)
        .textStyle(.body.helper.regular)
        .foregroundColor(.ds.text.neutral.quiet)
        .padding(.bottom, 2)

      Text(L10n.Core.plansCguMore)
        .textStyle(.body.helper.regular)
        .foregroundColor(.ds.text.neutral.quiet)
        .padding(.bottom, 4)

      HStack {
        Button(L10n.Core.kwCreateAccountPrivacy) { action(.policyPrivacy) }
          .buttonStyle(.externalLink)
          .controlSize(.small)

        Button(L10n.Core.kwCreateAccountTermsConditions) { action(.termsAndConditions) }
          .buttonStyle(.externalLink)
          .controlSize(.small)
      }
      .padding(.bottom, 12)
    }

    @ViewBuilder var backButton: some View {
      if firstStep {
        NavigationBarButton(action: { action(.cancel) }, title: L10n.Core.cancel)
      }
    }

    private func buy(duration: PaymentsAccessibleStoreOffersDuration) {
      guard let plan = model.planTier.plans.first(where: { $0.offer.duration == duration }) else {
        return
      }
      action(.buy(plan))
    }
  }

  struct PlanPurchaseView_Previews: PreviewProvider {
    static let capabilities = PaymentsAccessibleStoreOffersCapabilities(
      dataLeak: .init(enabled: true, info: nil), secureWiFi: .init(enabled: true, info: nil))
    static let planGroup = PlanTier(
      kind: .premium,
      plans: [
        PurchasePlan(
          subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .monthly, enabled: true),
          kind: .premium,
          capabilities: capabilities,
          isCurrentSubscription: true),
        PurchasePlan(
          subscription: .init(id: "id", price: 42, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .yearly, enabled: true),
          kind: .premium,
          capabilities: capabilities,
          isCurrentSubscription: false),
      ],
      capabilities: capabilities)

    static var previews: some View {
      MultiContextPreview {
        PlanPurchaseView(model: PlanPurchaseViewModel(planTier: planGroup), firstStep: false) { _ in
        }
      }
    }
  }
#endif
