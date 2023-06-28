import Foundation
import DesignSystem
import UIComponents
import CorePremium
import SwiftUI
import CoreLocalization

struct FeatureBadge: View {
    let status: Status

    init(_ status: Status) {
        self.status = status
    }

    var body: some View {
        Badge(status.title)
            .accessibilityLabel(Text(status.accessibilityLabel))
    }
}

extension FeatureBadge {
    enum Status {
        case beta
        case upgrade

        init?(capabilityState: CapabilityState) {
            switch capabilityState {
            case .available(let beta):
                guard beta else { return nil }
                self = .beta
            case .needsUpgrade:
                self = .upgrade
            case .unavailable:
                return nil
            }
        }

        var title: String {
            switch self {
            case .beta:
                return L10n.Localizable.localPasswordChangerSettingsNote
            case .upgrade:
                return CoreLocalization.L10n.Core.paywallUpgradetag
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .beta:
                return L10n.Localizable.accessibilityToolsBadgeNew
            case .upgrade:
                return L10n.Localizable.accessibilityToolsBadgeUpgrade
            }
        }
    }
}
struct FeatureBadge_Previews: PreviewProvider {
    static var previews: some View {
        FeatureBadge(.upgrade)
        FeatureBadge(.beta)
    }
}
