import DesignSystem
import SwiftUI

struct PaywallFeaturesBox<Content: View>: View {
  @ViewBuilder
  let content: () -> Content

  var body: some View {
    ViewThatFits(in: .vertical) {
      innerBody

      ScrollView {
        innerBody
      }
    }
  }

  var innerBody: some View {
    VStack(alignment: .leading, spacing: 16) {
      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.ds.container.agnostic.neutral.supershy, in: .containerRelative)
    .containerShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    .style(mood: .brand)
    .multilineTextAlignment(.leading)
  }
}

struct PaywallFeatureRow: View {
  let markdown: String
  let icon: Image

  init(markdown: String, icon: Image) {
    self.markdown = markdown
    self.icon = icon
  }

  var body: some View {
    HStack(spacing: 8) {
      DS.ExpressiveIcon(icon)
        .style(intensity: .quiet)
      Text((try? AttributedString(markdown: markdown)) ?? AttributedString(markdown))
        .textStyle(.body.standard.regular)
        .fixedSize(horizontal: false, vertical: true)

    }
    .controlSize(.small)
  }
}

#Preview {
  PaywallFeaturesBox {
    Badge("Premium Features", icon: .ds.premium.outlined)

    PaywallFeatureRow(
      markdown: "Unlimited **password storage** — never worry about space.",
      icon: .ds.item.login.outlined)
    PaywallFeatureRow(
      markdown: "**Share credentials** easily with others.", icon: .ds.shared.outlined)
    PaywallFeatureRow(
      markdown: "**Sync across all devices** for instant access.",
      icon: .ds.feature.authenticator.outlined)
  }
}
