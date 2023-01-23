import Foundation
import CorePremium
import StoreKit
import CoreLocalization

extension PurchasePlan.Kind {
    var localizedTitle: String {
        switch self {
            case .free:
                return L10n.Core.plansFreeDescription
            case .essentials:
                return L10n.Core.plansEssentialsTitle
            case .advanced:
                return L10n.Core.plansAdvancedTitle
            case .premium:
                return L10n.Core.plansPremiumTitle
            case .family:
                return L10n.Core.plansFamilyTitle
        }
    }

    var localizedDescription: String {
        switch self {
            case .free:
                return L10n.Core.planScreensFreePlanDescription
            case .essentials:
                return L10n.Core.plansEssentialsDescription
            case .advanced:
                return L10n.Core.plansAdvancedDescription
            case .premium:
                return L10n.Core.plansPremiumDescription
            case .family:
                return L10n.Core.plansFamilyDescription
        }
    }
}

extension PurchasePlan {
    var localizedTitle: String {
        kind.localizedTitle
    }

    var localizedDescription: String {
        kind.localizedDescription
    }
}

extension PlanTier {
    var localizedTitle: String {
        kind.localizedTitle
    }

    var localizedDescription: String {
        kind.localizedDescription
    }
}
