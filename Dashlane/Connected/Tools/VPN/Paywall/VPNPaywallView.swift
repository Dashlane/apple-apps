import SwiftUI
import UIDelight
import SwiftTreats
import UIComponents
import DesignSystem

struct VPNPaywallView: View {

    enum PaywallReason {
        case trialPeriod
        case upgradeNeeded
    }

    @Environment(\.dismiss)
    private var dismiss

    var reason: PaywallReason
    var primaryButtonAction: () -> Void
    var secondaryButtonAction: () -> Void

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    content
                        .padding(16)
                        .frame(minHeight: geo.frame(in: .global).height)
                }
                .background(Color.ds.background.default.edgesIgnoringSafeArea(.all))
                .accentColor(FiberAsset.accentColor.swiftUIColor)
                .toolbar {
                    Button(action: { dismiss() },
                           label: {
                        Text(L10n.Localizable.kwButtonClose)
                            .foregroundColor(Color(asset: FiberAsset.accentColor))
                    })
                }
            }
            .reportPageAppearance(.paywallVpn)
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 32) {
                VPNPaywallHeaderView(title: reason.headerTitle, description: reason.headerDescription)
                VStack(alignment: .leading, spacing: 24) {
                    makeItemView(image: Image(asset: FiberAsset.paywallIconShield),
                                 title: L10n.Localizable.mobileVpnPaywallProtectionTitle,
                                 description: L10n.Localizable.mobileVpnPaywallProtectionDescription)

                    makeItemView(image: Image(asset: FiberAsset.paywallIconWeb),
                                 title: L10n.Localizable.mobileVpnPaywallFullContentTitle,
                                 description: L10n.Localizable.mobileVpnPaywallFullContentDescription)
                }
            }
            .frame(maxWidth: .infinity, alignment: Device.isIpadOrMac ? .center : .leading)

            Spacer(minLength: 32)

            VStack(spacing: 6) {
                RoundedButton(L10n.Localizable.mobileVpnPaywallUpgradeToPremium,
                              action: { primaryButtonAction() })
                .roundedButtonLayout(.fill)

                Button(L10n.Localizable.mobileVpnPaywallSeePlanOptions, action: { secondaryButtonAction() })
                    .buttonStyle(BorderlessActionButtonStyle())
            }
        }.padding(.bottom, 16)
    }

    @ViewBuilder
    private func makeItemView(image: Image, title: String, description: String) -> some View {
        HStack(alignment: .iconHeaderAlignment, spacing: 4) {
            image
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color(asset: FiberAsset.accentColor))
                .frame(width: 40, height: 40)
                .alignmentGuide(.iconHeaderAlignment, computeValue: { $0[VerticalAlignment.center] })
                .fiberAccessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(Color(asset: FiberAsset.dashGreen))
                    .font(.custom(GTWalsheimPro.medium.name, size: 20, relativeTo: .title3))
                    .alignmentGuide(.iconHeaderAlignment, computeValue: { $0[VerticalAlignment.center] })
                Text(description)
                    .foregroundColor(Color(asset: FiberAsset.neutralText))
                    .font(.body)
            }
            .fiberAccessibilityElement(children: .combine)
        }
    }
}

struct VPNPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VPNPaywallView(reason: .trialPeriod, primaryButtonAction: {}, secondaryButtonAction: {})
            VPNPaywallView(reason: .upgradeNeeded, primaryButtonAction: {}, secondaryButtonAction: {})
        }
    }
}

fileprivate extension VPNPaywallView.PaywallReason {
    var headerTitle: String {
        switch self {
            case .trialPeriod:
                return L10n.Localizable.mobileVpnPaywallTrialHeaderTitle
            case .upgradeNeeded:
                return L10n.Localizable.mobileVpnPaywallUpgradeHeaderTitle
        }
    }

    var headerDescription: VPNPaywallHeaderView.Description {
        switch self {
            case .trialPeriod:
                return .text(L10n.Localizable.mobileVpnPaywallTrialHeaderDescription)
            case .upgradeNeeded:
                return .text(L10n.Localizable.mobileVpnPaywallUpgradeHeaderDescription)
        }
    }
}

extension VerticalAlignment {
    private enum IconHeaderAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[VerticalAlignment.center]
        }
    }

    fileprivate static let iconHeaderAlignment = VerticalAlignment(IconHeaderAlignment.self)
}
