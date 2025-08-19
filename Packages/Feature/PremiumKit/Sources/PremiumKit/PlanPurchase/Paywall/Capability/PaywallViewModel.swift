import Combine
import CoreLocalization
import CorePremium
import Foundation
import SwiftUI
import UserTrackingFoundation

public struct PaywallViewModel {
  public struct OldPaywallContent {
    let image: Image
    let title: String
    let text: String
  }

  let capability: CapabilityKey
  let page: Page
  let upgradePlanKind: PurchasePlan.Kind?
  let purchasePlanGroup: PlanTier?
  let statusProvider: PremiumStatusProvider

  public init?(
    capability: CapabilityKey, purchasePlanGroup: PlanTier?, statusProvider: PremiumStatusProvider
  ) {
    self.capability = capability
    self.purchasePlanGroup = purchasePlanGroup
    self.statusProvider = statusProvider
    self.upgradePlanKind = purchasePlanGroup?.kind
    self.page = capability.page
  }
}

extension PaywallViewModel {
  var upgradeText: String? {
    return upgradePlanKind.map { $0.upgradeText }
  }
}

extension PaywallViewModel {
  var oldContent: PaywallViewModel.OldPaywallContent? {
    switch capability {
    case .secureWiFi:
      return PaywallViewModel.OldPaywallContent(
        image: .ds.feature.vpn.outlined,
        title: CoreL10n.paywallsVpnTitle,
        text: CoreL10n.paywallsVpnMessage)
    case .securityBreach:
      return PaywallViewModel.OldPaywallContent(
        image: .ds.feature.darkWebMonitoring.outlined,
        title: CoreL10n.paywallsDwmTitle,
        text: CoreL10n.paywallsDwmMessage)
    case .sharingLimit:
      return PaywallViewModel.OldPaywallContent(
        image: .ds.shared.outlined,
        title: CoreL10n.paywallsSharingLimitTitle,
        text: CoreL10n.paywallsSharingLimitMessage)
    case .secureNotes:
      return PaywallViewModel.OldPaywallContent(
        image: .ds.item.secureNote.outlined,
        title: CoreL10n.paywallsSecureNotesTitle,
        text: CoreL10n.paywallsSecureNotesPremiumMessage)
    case .passwordsLimit:
      return PaywallViewModel.OldPaywallContent(
        image: .ds.premium.outlined,
        title: CoreL10n.paywallsPasswordLimitTitle,
        text: CoreL10n.paywallsPasswordLimitAddManually)
    default: return nil
    }
  }
}

extension CapabilityKey {
  fileprivate var page: Page {
    switch self {
    case .secureWiFi: return .paywallVpn
    case .securityBreach: return .paywallDarkWebMonitoring
    case .sharingLimit: return .paywallSharingLimit
    case .secureNotes: return .paywallSecureNotes
    case .passwordsLimit: return .paywallFreeUserPasswordLimitReached
    default: return .paywall
    }
  }
}

extension PurchasePlan.Kind {
  fileprivate var upgradeText: String {
    switch self {
    case .premium:
      return CoreL10n.paywallsUpgradeToPremiumCTA
    case .essentials:
      return CoreL10n.paywallsUpgradeToEssentialsCTA
    case .advanced:
      return CoreL10n.paywallsUpgradeToAdvancedCTA
    default:
      return ""
    }
  }
}
