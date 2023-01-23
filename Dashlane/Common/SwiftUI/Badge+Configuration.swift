import Foundation
import DesignSystem
import UIComponents
import CorePremium

enum BadgeConfiguration {
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
                return L10n.Localizable.paywallUpgradetag
        }
    }

    var mood: Mood {
        switch self {
            case .beta, .upgrade:
                return .brand
        }
    }

    var intensity: Intensity {
        switch self {
        case .upgrade, .beta:
                return .quiet
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
