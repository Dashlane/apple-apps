import SwiftUI
import Combine
import CorePremium
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

public struct PaywallView: View {

    public enum Action {
        case displayList
        case planDetails(PlanTier)
        case cancel
    }

    let model: PaywallViewModel
    let shouldDisplayCloseButton: Bool

    let action: (Action) -> Void

    public init(model: PaywallViewModel,
                shouldDisplayCloseButton: Bool,
                action: @escaping (Action) -> Void) {
        self.model = model
        self.shouldDisplayCloseButton = shouldDisplayCloseButton
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                model.image.swiftUIImage
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 84, height: 84)
                    .animation(nil, value: model.image.name)
                    .foregroundColor(.ds.text.neutral.standard)

                Text(model.title)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(DashlaneFont.custom(26, .bold).font)
                    .fontWeight(.bold)

                Text(model.text)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(.system(size: 17))
                    .fontWeight(.regular)
            }
            Spacer()
            VStack(alignment: .center, spacing: 6) {
                if let kind = model.upgradePlanKind, let planGroup = model.purchasePlanGroup {
                    RoundedButton(kind.upgradeText, action: { action(.planDetails(planGroup)) })
                        .roundedButtonLayout(.fill)

                    Button(L10n.Core.paywallsPlanOptionsCTA, action: { action(.displayList) })
                        .buttonStyle(BorderlessActionButtonStyle())
                } else {
                    RoundedButton(L10n.Core.paywallsPlanOptionsCTA, action: { action(.displayList) })
                        .roundedButtonLayout(.fill)
                }
            }
            .padding(.bottom, 36)
            Spacer()
        }
        #if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton.hidden(!shouldDisplayCloseButton)
            }
        }
        #endif
        .padding(.horizontal, 24)
        .reportPageAppearance(model.page)
    }

    private var closeButton: some View {
        NavigationBarButton(action: { action(.cancel) }, label: { Text(L10n.Core.kwButtonClose) })
    }
}

#if canImport(UIKit)
struct PaywallView_Previews: PreviewProvider {
    static let previewedCapabilities: [CapabilityKey] = [
        .secureNotes,
        .dataLeak,
        .sharingLimit,
        .secureWiFi
    ]

    static var previews: some View {
        ForEach(previewedCapabilities, id: \.rawValue) { capability in
            MultiContextPreview {
                PaywallViewModel(capability, purchasePlanGroup: PurchasePlanRowView_Previews.planTier).map { PaywallView(model: $0, shouldDisplayCloseButton: false, action: { _ in }) }
                    .background(.ds.background.default)
            }
        }
        MultiContextPreview {
            PaywallViewModel(.secureNotes, purchasePlanGroup: nil).map { PaywallView(model: $0, shouldDisplayCloseButton: false, action: { _ in }) }
                .background(.ds.background.default)
        }
    }
}
#endif


extension PurchasePlan.Kind {
    var upgradeText: String {
        switch self {
        case .premium:
            return L10n.Core.paywallsUpgradeToPremiumCTA
        case .essentials:
            return L10n.Core.paywallsUpgradeToEssentialsCTA
        case .advanced:
                        return ""
        default:
            return ""
        }
    }
}
