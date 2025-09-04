import CoreLocalization
import DesignSystem
import SwiftUI

struct FrozenPaywall: View {
  let l10n = CoreL10n.FrozenPaywall.self
  let wasOnTrial: Bool
  let completion: (PaywallView.Action) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      VStack(alignment: .center, spacing: 12) {
        Text(l10n.title)
          .textStyle(.specialty.brand.medium)
          .fixedSize(horizontal: false, vertical: true)
        Text(wasOnTrial ? l10n.Body.regular : l10n.Body.trialEnded)
          .textStyle(.title.block.small)
          .fixedSize(horizontal: false, vertical: true)
      }

      PaywallFeaturesBox {
        Badge(CoreL10n.plansPremiumTitle, icon: .ds.premium.outlined)

        let featuresL10n = l10n.Features.self
        PaywallFeatureRow(markdown: featuresL10n.storageMarkdown, icon: .ds.item.login.outlined)
        PaywallFeatureRow(
          markdown: featuresL10n.autofillMarkdown, icon: .ds.feature.autofill.outlined)
        PaywallFeatureRow(markdown: featuresL10n.shareMarkdown, icon: .ds.shared.outlined)
        PaywallFeatureRow(
          markdown: featuresL10n.syncMarkdown, icon: .ds.feature.authenticator.outlined)
        PaywallFeatureRow(
          markdown: featuresL10n.secureMarkdown, icon: .ds.feature.darkWebMonitoring.outlined)
      }
      .frame(maxHeight: .infinity, alignment: .top)

      Text(l10n.footer)
        .textStyle(.body.helper.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)

      Button(l10n.upgradeButton) {
        completion(.displayList)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
    .multilineTextAlignment(.center)
    .foregroundStyle(Color.ds.text.neutral.standard)
    .background(Color.ds.background.alternate.edgesIgnoringSafeArea(.all))
    .reportPageAppearance(.paywallFreeUserPasswordLimitReached)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(CoreL10n.kwButtonClose) {
          completion(.cancel)
        }
      }
    }
  }
}

#Preview("Frozen from Trial") {
  NavigationView {
    FrozenPaywall(wasOnTrial: true) { _ in

    }
  }
}

#Preview("Frozen after preimium ended") {
  NavigationView {
    FrozenPaywall(wasOnTrial: false) { _ in

    }
  }
}
