import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight

struct VPNTeamFeatureDisabledView: View {

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    VStack {
      VPNPaywallHeaderView(
        title: L10n.Localizable.vpnTeamPaywallTitle,
        description: .text(L10n.Localizable.vpnTeamPaywallSubtitle)
      )
      .frame(maxWidth: .infinity, alignment: Device.isIpadOrMac ? .center : .leading)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay(
      alignment: .topLeading,
      content: {
        Button(
          action: { dismiss() },
          title: CoreLocalization.L10n.Core.kwButtonClose
        )
        .foregroundColor(.ds.text.brand.standard)
      }
    )
    .padding(16)
    .backgroundColorIgnoringSafeArea(.ds.container.agnostic.neutral.standard)
    .reportPageAppearance(.paywallVpn)
  }
}

struct VPNTeamFeatureDisabledView_Previews: PreviewProvider {
  static var previews: some View {
    VPNTeamFeatureDisabledView()
  }
}
