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
    @StateObject
    var model: PurchasePlanRowModel

    init(model: @autoclosure @escaping () -> PurchasePlanRowModel) {
      self._model = .init(wrappedValue: model())
    }

    var body: some View {
      VStack(alignment: .leading) {
        if let promotionalMessage = model.promotionalMessage {
          Badge(promotionalMessage)
            .style(mood: .positive, intensity: .quiet)
            .padding(.top, 12)
            .padding(.horizontal, 16)
        }

        HStack {
          if model.hasLock {
            Image.ds.lock.outlined
              .resizable()
              .frame(width: 25, height: 25)
              .foregroundColor(.ds.text.brand.standard)
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

            if model.showPrice {
              priceView
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)

        Spacer()

        if let warning = model.frozenWarning {
          MarkdownText(warning)
            .font(.footnote)
            .foregroundColor(.ds.text.danger.standard)
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
            .multilineTextAlignment(.leading)
        } else {
          MarkdownText(model.plan.localizedDescription)
            .font(.footnote)
            .foregroundColor(.ds.text.neutral.standard)
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
            .multilineTextAlignment(.leading)
        }
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
    static func plan(kind: PurchasePlan.Kind, duration: PaymentsAccessibleStoreOffersDuration)
      -> PurchasePlan
    {
      return PurchasePlan(
        subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
        offer: PaymentsAccessibleStoreOffers(
          planName: "",
          duration: duration,
          enabled: true
        ),
        kind: kind,
        capabilities: PaymentsAccessibleStoreOffersCapabilities(),
        isCurrentSubscription: false
      )
    }

    static func planTier(kind: PurchasePlan.Kind) -> PlanTier {
      return PlanTier(
        plans: [plan(kind: kind, duration: .monthly), plan(kind: kind, duration: .yearly)],
        capabilities: PaymentsAccessibleStoreOffersCapabilities()
      )
    }

    static var previews: some View {
      MultiContextPreview {
        PurchasePlanRowView(
          model: PurchasePlanRowModel(
            planTier: planTier(kind: .advanced), plan: plan(kind: .advanced, duration: .monthly),
            vaultStateService: .mock)
        )
        .backgroundColorIgnoringSafeArea(.ds.background.default)

        PurchasePlanRowView(
          model: PurchasePlanRowModel(
            planTier: planTier(kind: .free), plan: plan(kind: .free, duration: .monthly),
            vaultStateService: .mock)
        )
        .backgroundColorIgnoringSafeArea(.ds.background.default)
      }
      .previewLayout(.sizeThatFits)
      .frame(maxHeight: 200)
    }
  }
#endif
