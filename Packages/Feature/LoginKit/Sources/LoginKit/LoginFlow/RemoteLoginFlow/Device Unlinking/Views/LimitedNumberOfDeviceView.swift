import SwiftUI
import CoreSession
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

public struct LimitedNumberOfDeviceView: View {
        public enum Action {
        case unlink
        case upgrade
        case logout
    }

        let mode: DeviceUnlinker.UnlinkMode
    let action: (Action) -> Void

    public init(mode: DeviceUnlinker.UnlinkMode,
                action: @escaping (Action) -> Void) {
        self.mode = mode
        self.action = action
    }

        public var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            header
                .frame(maxHeight: .infinity, alignment: .center)
            actions
        }
        .padding(26)
        .loginAppearance()
        #if canImport(UIKit)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(L10n.Core.kwLogOut, action: logout)
            }
        }
        #endif
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 13) {
            VStack(spacing: 10) {
                Image(asset: Asset.multidevices)

                Text(mode.title)
                    .font(DashlaneFont.custom(26, .bold).font)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(mode.description)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)

            if case DeviceUnlinker.UnlinkMode.multiple = mode {
                Infobox(title: L10n.Core.deviceUnlinkUnlinkDevicePremiumFeatureDescription)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var actions: some View {
        VStack(alignment: .center, spacing: 5) {
            RoundedButton(L10n.Core.deviceUnlinkingLimitedPremiumCta, action: upgrade)
            RoundedButton(mode.unlinkButtonLabel, action: unlink)
                .style(mood: .brand, intensity: .quiet)

        }
        .roundedButtonLayout(.fill)
    }

        private func upgrade() {
        action(.upgrade)
    }

    private func unlink() {
        action(.unlink)
    }

    private func logout() {
        action(.logout)
    }
}

private extension DeviceUnlinker.UnlinkMode {
    var title: String {
        switch self {
            case .monobucket:
                return L10n.Core.deviceUnlinkingLimitedTitle
            case let .multiple(limit):
                return L10n.Core.deviceUnlinkLimitedMultiDevicesTitle(limit)
        }
    }

    var description: String {
        switch self {
            case .monobucket:
                return L10n.Core.deviceUnlinkingLimitedDescription
            case .multiple:
                return L10n.Core.deviceUnlinkLimitedMultiDevicesDescription
        }
    }

    var unlinkButtonLabel: String {
        switch self {
            case .monobucket:
                return L10n.Core.deviceUnlinkingLimitedUnlinkCta
            case .multiple:
                return L10n.Core.deviceUnlinkLimitedMultiDevicesUnlinkCta
        }
    }

}

struct LimitedNumberOfDevice_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
                    NavigationView {
                        LimitedNumberOfDeviceView(mode: .monobucket) { _ in
                        }
                    }
                    NavigationView {
                        LimitedNumberOfDeviceView(mode: .multiple(2)) { _ in
                        }
                    }
                }
    }
}
