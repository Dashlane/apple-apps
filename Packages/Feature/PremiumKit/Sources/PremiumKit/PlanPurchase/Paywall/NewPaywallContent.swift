import CoreLocalization
import CorePremium
import SwiftUI

public struct NewPaywallContent {
  let banner: ImageAsset
  let title: String
  let features: [Feature]
  let link: Link?

  public struct Feature: Identifiable {
    public var id: String {
      description
    }

    let asset: SwiftUI.Image
    let description: String
  }

  struct Link {
    let label: String
    let url: URL
  }
}

extension NewPaywallContent {
  public init?(trigger: PaywallViewModel.Trigger) {
    switch trigger {
    case .capability(let key):
      switch key {
      case .secureWiFi:
        self.banner = Asset.hotspot
        self.title = L10n.Core.paywallsVPNTitle
        self.features = [
          Feature(asset: .ds.feature.vpn.outlined, description: L10n.Core.paywallsVPNHotspot),
          Feature(asset: .ds.healthPositive.outlined, description: L10n.Core.paywallsVPNEncryption),
          Feature(asset: .ds.web.outlined, description: L10n.Core.paywallsVPNLocations),
        ]
        self.link = URL(string: "_").map({ url in
          Link(label: L10n.Core.paywallsVPNLink, url: url)
        })
      case .securityBreach:
        self.banner = Asset.pushIllustration
        self.title = L10n.Core.paywallsDWMTitle
        self.features = [
          Feature(
            asset: .ds.feature.darkWebMonitoring.outlined,
            description: L10n.Core.paywallsDWMWebScanning),
          Feature(asset: .ds.notification.outlined, description: L10n.Core.paywallsDWMAlerts),
          Feature(asset: .ds.unlock.outlined, description: L10n.Core.paywallsDWMSecure),
        ]
        self.link = nil
      case .passwordsLimit:
        self.banner = Asset.paywallDiamond
        self.title = L10n.Core.paywallsPasswordLimit
        self.features = [
          Feature(
            asset: .ds.item.login.outlined,
            description: L10n.Core.paywallsPasswordLimitAddManually),
          Feature(
            asset: .ds.feature.authenticator.outlined,
            description: L10n.Core.paywallsPasswordLimitSync),
          Feature(
            asset: .ds.feature.darkWebMonitoring.outlined,
            description: L10n.Core.paywallsPasswordLimitOtherFeatures),
        ]
        self.link = nil
      default:
        return nil
      }
    case .frozenAccount:
      self.banner = Asset.frozen
      self.title = L10n.Core.paywallsFrozenTitleReadOnly
      self.features = [
        Feature(asset: .ds.unlock.outlined, description: L10n.Core.paywallsFrozenFeatureStorage),
        Feature(
          asset: .ds.feature.authenticator.outlined,
          description: L10n.Core.paywallsFrozenFeatureSync),
        Feature(asset: .ds.web.outlined, description: L10n.Core.paywallsFrozenFeatureDWMandVPN),
      ]
      self.link = URL(string: "_").map({ url in
        Link(label: L10n.Core.paywallsFrozenLearnMore, url: url)
      })
    }
  }
}
