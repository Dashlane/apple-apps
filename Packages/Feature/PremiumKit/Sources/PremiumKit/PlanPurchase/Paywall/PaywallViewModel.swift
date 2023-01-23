import Foundation
import CorePremium
import Combine
import CoreUserTracking
import CoreLocalization

public struct PaywallViewModel {

    let image: ImageAsset
    let title: String
    let text: String
    let page: Page
    let upgradePlanKind: PurchasePlan.Kind?
    let purchasePlanGroup: PlanTier?

    public init?(_ capability: CapabilityKey, purchasePlanGroup: PlanTier?) {
        self.purchasePlanGroup = purchasePlanGroup
        self.upgradePlanKind = purchasePlanGroup?.kind
        self.page = capability.page

        guard let image = capability.image, let title = capability.title, let text = capability.text(upgradePlanKind: upgradePlanKind) else {
            return nil
        }
        self.image = image
        self.title = title
        self.text = text
    }
}

fileprivate extension CapabilityKey {
    var image: ImageAsset? {
        switch self {
        case .secureWiFi:       return Asset.paywallVpn
        case .securityBreach:   return Asset.paywallDwm
        case .sharingLimit:     return Asset.sharingPaywall
        case .secureNotes:      return Asset.paywallSecurenotes
        default:                return nil
        }
    }

    var title: String? {
        switch self {
        case .secureWiFi:       return L10n.Core.paywallsVpnTitle
        case .securityBreach:   return L10n.Core.paywallsDwmTitle
        case .sharingLimit:     return L10n.Core.paywallsSharingLimitTitle
        case .secureNotes:      return L10n.Core.paywallsSecureNotesTitle
        default:                return nil
        }
    }

    func text(upgradePlanKind: PurchasePlan.Kind?) -> String? {
        switch self {
        case .secureWiFi:       return L10n.Core.paywallsVpnMessage
        case .securityBreach:   return L10n.Core.paywallsDwmMessage
        case .secureNotes:      return L10n.Core.paywallsSecureNotesPremiumMessage
        default:                return nil
        }
    }

    var page: Page {
        switch self {
        case .secureWiFi:   return .paywallVpn
        case .securityBreach: return .paywallDarkWebMonitoring
        case .sharingLimit: return .paywallSharingLimit
        case .secureNotes:  return .paywallSecureNotes
        default: return .paywall
        }
    }
}
