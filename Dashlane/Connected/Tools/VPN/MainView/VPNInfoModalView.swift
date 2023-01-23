import SwiftUI
import UIDelight
import UIComponents
import DesignSystem

struct VPNInfoModalView: View {

    let buttonAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Image(asset: FiberAsset.vpnOutlined)
                    .resizable()
                    .foregroundColor(Color(asset: FiberAsset.dashGreen))
                    .frame(width: 48, height: 48)
                    .fiberAccessibilityHidden(true)

                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.Localizable.mobileVpnNewProviderInfoModalTitle)
                        .font(.custom(GTWalsheimPro.medium.name, size: 26, relativeTo: .title))
                        .foregroundColor(Color(asset: FiberAsset.dashGreen))

                    Text(Self.makeDescriptionText)
                }
            }

            RoundedButton(L10n.Localizable.mobileVpnNewProviderInfoModalButtonTitle,
                          action: { buttonAction() })
            .roundedButtonLayout(.fill)

        }
        .padding(EdgeInsets(top: 26, leading: 16, bottom: 26, trailing: 16))
        .background(Color(asset: FiberAsset.mainBackground))
    }

    private static var makeDescriptionText: AttributedString {
        var attributedString = AttributedString(L10n.Localizable.mobileVpnNewProviderInfoModalDescription)
        attributedString.foregroundColor = .ds.text.neutral.quiet
        attributedString.font = .system(.callout)

        if let urlRange = attributedString.range(of: "Hotspot Shield") {
            attributedString[urlRange].link = URL(string: "_")!
            attributedString[urlRange].foregroundColor = .ds.text.brand.standard
        }

        return attributedString
    }
}

struct VPNInfoModalView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VPNInfoModalView(buttonAction: {})
        }
        .previewLayout(.sizeThatFits)
    }
}
