import CoreLocalization
import CorePremium
import CoreTypes
import DashlaneAPI
import DesignSystem
import Foundation
import StoreKit
import SwiftUI
import UIComponents
import UIDelight

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
            .foregroundStyle(Color.ds.text.brand.standard)
        }

        HStack(alignment: .firstTextBaseline) {
          VStack(alignment: .leading) {
            Text(model.plan.localizedTitle)
              .textStyle(.title.section.medium)
              .foregroundStyle(Color.ds.text.brand.standard)
            if model.plan.isCurrentSubscription {
              Text(CoreL10n.plansOnGoingPlan)
                .textStyle(.body.helper.regular)
                .foregroundStyle(Color.ds.text.neutral.standard)
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
          .foregroundStyle(Color.ds.text.danger.standard)
          .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
          .multilineTextAlignment(.leading)
      } else {
        MarkdownText(model.plan.localizedDescription)
          .font(.footnote)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
          .multilineTextAlignment(.leading)
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 5.0).foregroundStyle(
        Color.ds.container.agnostic.neutral.standard)
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
            .foregroundStyle(Color.ds.text.neutral.quiet)
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
      .foregroundStyle(Color.ds.text.neutral.standard)

      if let renewalPriceDescription = model.renewalPriceDescription {
        Text(renewalPriceDescription)
          .font(.caption)
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
    }
  }
}

extension CoreL10n {
  static func plansPriceBilled(for periodicity: PaymentsAccessibleStoreOffersDuration) -> String {
    switch periodicity {
    case .monthly:
      return CoreL10n.plansPriceBilledMonthly("")
    case .yearly:
      return CoreL10n.plansPriceBilledYearly("")
    case .undecodable:
      return ""
    }
  }
}

#if DEBUG
  #Preview("Advanced Plan", traits: .sizeThatFitsLayout) {
    PurchasePlanRowView(
      model: PurchasePlanRowModel(
        planTier: PlanPreviewUtilities.planTier(kind: .advanced),
        plan: PlanPreviewUtilities.plan(kind: .advanced, duration: .monthly),
        vaultStateService: .mock())
    )
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .frame(maxHeight: 200)
  }

  #Preview("Free Plan", traits: .sizeThatFitsLayout) {
    PurchasePlanRowView(
      model: PurchasePlanRowModel(
        planTier: PlanPreviewUtilities.planTier(kind: .free),
        plan: PlanPreviewUtilities.plan(kind: .free, duration: .monthly),
        vaultStateService: .mock())
    )
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .frame(maxHeight: 200)
  }
#endif
