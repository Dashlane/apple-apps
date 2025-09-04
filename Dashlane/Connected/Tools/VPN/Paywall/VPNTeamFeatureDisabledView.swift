import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight

struct VPNTeamFeatureDisabledView: View {

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    VStack(alignment: .center, spacing: 24) {
      Spacer()

      DS.ExpressiveIcon(.ds.feature.vpn.outlined)
        .controlSize(.extraLarge)
        .style(mood: .neutral, intensity: .quiet)
        .fiberAccessibilityHidden(true)

      VStack(alignment: .center, spacing: 8) {
        Text(L10n.Localizable.vpnTeamPaywallTitle)
          .textStyle(.title.section.large)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(Color.ds.text.neutral.catchy)

        Text(L10n.Localizable.vpnTeamPaywallSubtitle)
          .textStyle(.body.reduced.regular)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .multilineTextAlignment(.center)
      }

      Spacer()

      Button(CoreL10n.kwButtonClose) {
        dismiss()
      }
      .buttonStyle(.designSystem(.titleOnly))

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(16)
    .background(Color.ds.container.agnostic.neutral.standard, ignoresSafeAreaEdges: .all)
    .reportPageAppearance(.paywallVpn)
  }
}

#Preview {
  VPNTeamFeatureDisabledView()
}
