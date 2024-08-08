#if canImport(UIKit)

  import Foundation
  import SwiftUI
  import CorePremium
  import StoreKit
  import UIDelight
  import UIComponents
  import DesignSystem
  import CoreLocalization
  import DashlaneAPI

  struct PurchasePlanRowView: View {
    let model: PurchasePlanRowModel

    var body: some View {
      VStack(alignment: .leading) {
        if let promotionalMessage = model.promotionalMessage {
          Badge(promotionalMessage)
            .style(mood: .positive, intensity: .quiet)
            .padding(.top, 12)
            .padding(.horizontal, 16)
        }

        HStack(alignment: .firstTextBaseline) {
          VStack(alignment: .leading) {
            Text(model.plan.localizedTitle)
              .font(DashlaneFont.custom(26, .medium).font)
              .foregroundColor(.ds.text.brand.standard)
            if model.plan.isCurrentSubscription {
              Text(L10n.Core.plansOnGoingPlan)
                .font(.footnote)
                .foregroundColor(.ds.text.neutral.standard)
            }
          }

          Spacer()

          priceView
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)

        Spacer()

        MarkdownText(model.plan.localizedDescription)
          .font(.footnote)
          .foregroundColor(.ds.text.neutral.standard)
          .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
          .multilineTextAlignment(.leading)
      }
      .background(
        RoundedRectangle(cornerRadius: 5.0).foregroundColor(.ds.container.agnostic.neutral.standard)
      )
      .frame(minHeight: 159)
    }

    private var priceView: some View {
      VStack(alignment: .trailing, spacing: 5) {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          if model.showStrikedthroughPrice {
            Text(model.plan.localizedNonDiscountedPrice)
              .font(.caption)
              .strikethrough()
              .foregroundColor(.ds.text.neutral.quiet)
              .padding(.trailing, 8)
          }

          Text(model.plan.localizedPrice)
            .font(.body).bold()
            .id(model.plan.price)

          Text(model.periodDescription)
            .font(.caption)
            .padding(.leading, 2)
            .id(model.plan.offer.duration)
        }
        .foregroundColor(.ds.text.neutral.standard)

        if let renewalPriceDescription = model.renewalPriceDescription {
          Text(renewalPriceDescription)
            .font(.caption)
            .foregroundColor(.ds.text.neutral.quiet)
        }
      }
    }
  }

  extension L10n.Core {
    static func plansPriceBilled(for periodicity: PaymentsAccessibleStoreOffersDuration) -> String {
      switch periodicity {
      case .monthly:
        return L10n.Core.plansPriceBilledMonthly("")
      case .yearly:
        return L10n.Core.plansPriceBilledYearly("")
      case .undecodable:
        return ""
      }
    }
  }

  struct PurchasePlanRowView_Previews: PreviewProvider {
    static let plan = PurchasePlan(
      subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
      offer: PaymentsAccessibleStoreOffers(
        planName: "",
        duration: .monthly,
        enabled: true
      ),
      kind: .advanced,
      capabilities: PaymentsAccessibleStoreOffersCapabilities(),
      isCurrentSubscription: false
    )

    static let planTier = PlanTier(
      kind: .advanced,
      plans: [
        PurchasePlan(
          subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .monthly, enabled: true),
          kind: .advanced,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(),
          isCurrentSubscription: true
        ),
        PurchasePlan(
          subscription: .init(id: "id2", price: 42, purchaseAction: { _ in fatalError() }),
          offer: PaymentsAccessibleStoreOffers(planName: "", duration: .yearly, enabled: true),
          kind: .advanced,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(),
          isCurrentSubscription: false
        ),
      ],
      capabilities: PaymentsAccessibleStoreOffersCapabilities()
    )

    static var previews: some View {
      MultiContextPreview {
        PurchasePlanRowView(model: PurchasePlanRowModel(planTier: planTier, plan: plan))
          .backgroundColorIgnoringSafeArea(.ds.background.default)
      }
      .previewLayout(.sizeThatFits)
      .frame(maxHeight: 200)
    }
  }
#endif
