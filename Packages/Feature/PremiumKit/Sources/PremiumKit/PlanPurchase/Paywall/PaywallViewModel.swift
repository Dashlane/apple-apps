import Combine
import CoreLocalization
import CorePremium
import CoreUserTracking
import Foundation

public struct PaywallViewModel {

  public enum Trigger {
    case capability(key: CapabilityKey)
    case frozenAccount
  }

  public struct OldPaywallContent {
    let image: ImageAsset
    let title: String
    let text: String
  }

  let trigger: Trigger
  let page: Page
  let upgradePlanKind: PurchasePlan.Kind?
  let purchasePlanGroup: PlanTier?

  public init?(_ trigger: Trigger, purchasePlanGroup: PlanTier?) {
    self.trigger = trigger
    self.purchasePlanGroup = purchasePlanGroup
    self.upgradePlanKind = purchasePlanGroup?.kind
    self.page = trigger.page
  }
}

extension PaywallViewModel {
  var upgradeText: String? {
    if case .frozenAccount = trigger {
      return L10n.Core.paywallsFrozenCTARegain
    }

    return upgradePlanKind.map { $0.upgradeText }
  }
}

extension PaywallViewModel.Trigger {
  var oldContent: PaywallViewModel.OldPaywallContent? {
    switch self {
    case .capability(let key):
      switch key {
      case .secureWiFi:
        return PaywallViewModel.OldPaywallContent(
          image: Asset.paywallVpn,
          title: L10n.Core.paywallsVpnTitle,
          text: L10n.Core.paywallsVpnMessage)
      case .securityBreach:
        return PaywallViewModel.OldPaywallContent(
          image: Asset.paywallDwm,
          title: L10n.Core.paywallsDwmTitle,
          text: L10n.Core.paywallsDwmMessage)
      case .sharingLimit:
        return PaywallViewModel.OldPaywallContent(
          image: Asset.sharingPaywall,
          title: L10n.Core.paywallsSharingLimitTitle,
          text: L10n.Core.paywallsSharingLimitMessage)
      case .secureNotes:
        return PaywallViewModel.OldPaywallContent(
          image: Asset.paywallSecurenotes,
          title: L10n.Core.paywallsSecureNotesTitle,
          text: L10n.Core.paywallsSecureNotesPremiumMessage)
      case .passwordsLimit:
        return PaywallViewModel.OldPaywallContent(
          image: Asset.paywallDiamond,
          title: L10n.Core.paywallsPasswordLimitTitle,
          text: L10n.Core.paywallsPasswordLimitAddManually)
      default: return nil
      }
    case .frozenAccount:
      return nil
    }
  }

  var page: Page {
    switch self {
    case .capability(let key):
      return key.page
    case .frozenAccount:
      return .paywallFreeUserPasswordLimitReached
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
      return L10n.Core.paywallsUpgradeToPremiumCTA
    case .essentials:
      return L10n.Core.paywallsUpgradeToEssentialsCTA
    case .advanced:
      return L10n.Core.paywallsUpgradeToAdvancedCTA
    default:
      return ""
    }
  }
}
