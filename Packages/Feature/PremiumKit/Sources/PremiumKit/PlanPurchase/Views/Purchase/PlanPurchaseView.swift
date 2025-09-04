import Combine
import CoreLocalization
import CorePremium
import DashlaneAPI
import DesignSystem
import Foundation
import StoreKit
import SwiftUI
import UIComponents
import UIDelight

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

      Text(model.title)
        .textStyle(.title.section.medium)
        .foregroundStyle(Color.ds.text.brand.standard)
        .padding(.vertical, 12)

      if model.displayFrozenState {
        Infobox(
          CoreL10n.planScreensFreePageFrozenWarningTitle,
          description: CoreL10n.planScreensFreePageFrozenWarningDescription
        )
        .style(mood: .warning)
        .padding(.bottom, 20)
      }

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
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .reportPageAppearance(model.page)
  }

  @ViewBuilder
  var capabilities: some View {
    if let kind = model.kind, let capabilities = model.capabilities {
      PlanCapabilitiesView(
        kind: kind,
        capabilities: capabilities)
    }
  }

  @ViewBuilder
  var CTAs: some View {
    if model.displayFrozenState {
      Button(CoreL10n.planScreensFreeFrozenCTA) {
        model.goToVault()
      }
      .style(mood: .brand, intensity: .quiet)
      .buttonStyle(.designSystem(.titleOnly))
    } else {
      ForEach(model.ctas, id: \.title) { cta in
        Button(cta.title) {
          buy(duration: cta.duration)
        }
        .style(mood: .brand, intensity: cta.isLightColored ? .quiet : .catchy)
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(cta.enabled == false)
      }
    }
  }

  @ViewBuilder
  var termsAndConditionsPanel: some View {
    if !model.displayFrozenState {
      Text(CoreL10n.plansCguAppleId2)
        .textStyle(.body.helper.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .padding(.bottom, 2)

      Text(CoreL10n.plansCguMore)
        .textStyle(.body.helper.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .padding(.bottom, 4)

      HStack {
        Button(CoreL10n.kwCreateAccountPrivacy) { action(.policyPrivacy) }
          .buttonStyle(.externalLink)
          .controlSize(.small)
          .accessibilityAddTraits(.isLink)
          .accessibilityRemoveTraits(.isButton)

        Button(CoreL10n.kwCreateAccountTermsConditions) { action(.termsAndConditions) }
          .buttonStyle(.externalLink)
          .controlSize(.small)
          .accessibilityAddTraits(.isLink)
          .accessibilityRemoveTraits(.isButton)
      }
      .padding(.bottom, 12)
    }
  }

  @ViewBuilder var backButton: some View {
    if firstStep {
      Button(CoreL10n.cancel) {
        action(.cancel)
      }
    }
  }

  private func buy(duration: PaymentsAccessibleStoreOffersDuration) {
    guard let plan = model.plan(for: duration) else {
      return
    }
    action(.buy(plan))
  }
}

#Preview {
  let capabilities = PaymentsAccessibleStoreOffersCapabilities(
    dataLeak: .init(enabled: true, info: nil), secureWiFi: .init(enabled: true, info: nil))
  let planGroup = PlanTier(
    plans: [
      PurchasePlan(
        subscription: .init(id: "id", price: 42, purchaseAction: { _ in fatalError() }),
        offer: PaymentsAccessibleStoreOffers(planName: "", duration: .yearly, enabled: true),
        kind: .premium,
        capabilities: capabilities,
        isCurrentSubscription: false)
    ],
    capabilities: capabilities)

  PlanPurchaseView(
    model: PlanPurchaseViewModel(
      planDisplay: .tier(planGroup), deeplinkingService: PremiumKitDeepLinkingServiceMock()),
    firstStep: false
  ) { _ in }
}
