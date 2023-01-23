import SwiftUI
import UIDelight
import SwiftTreats

struct VPNTeamPaywallView: View {

    @Environment(\.navigator)
    private var navigator

    var body: some View {
        VStack {
            Spacer()
            VPNPaywallHeaderView(title: L10n.Localizable.vpnTeamPaywallTitle, description: .text(L10n.Localizable.vpnTeamPaywallSubtitle))
                .frame(maxWidth: .infinity, alignment: Device.isIpadOrMac ? .center : .leading)
            Spacer()
            Button(action: { navigator()?.dismiss() }, title: L10n.Localizable.kwButtonClose)
                .foregroundColor(Color(asset: FiberAsset.accentColor))
        }
        .padding(16)
        .background(Color(asset: FiberAsset.mainBackground).edgesIgnoringSafeArea(.all))
        .reportPageAppearance(.paywallVpn)
    }
}

struct VPNTeamPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VPNTeamPaywallView()
                .background(Color(asset: FiberAsset.mainBackground))
        }
    }
}
