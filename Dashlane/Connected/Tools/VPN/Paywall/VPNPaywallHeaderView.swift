import DesignSystem
import SwiftUI
import UIDelight
import UIComponents

struct VPNPaywallHeaderView: View {

    enum Description {
        case text(String)
        case attributedText(AttributedString)
    }

    let title: String
    let description: Description

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 26) {
                Image.ds.feature.vpn.outlined
                    .renderingMode(.template)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .fiberAccessibilityHidden(true)
                Text(title)
                    .font(.custom(GTWalsheimPro.medium.name, size: 26, relativeTo: .title))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.ds.text.neutral.catchy)
            }

            switch description {
                case .text(let description):
                    Text(description)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.ds.text.neutral.standard)
                        .lineLimit(nil)
                case .attributedText(let subtitle):
                    Text(subtitle)
            }
        }
    }
}

struct VPNPaywallHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VPNPaywallHeaderView(title: "VPN is disabled", description: .text("This feature has been disabled by your IT Admin."))
                .padding(16)
                .previewLayout(.sizeThatFits)
                .background(Color(asset: FiberAsset.mainBackground))
        }
    }
}
