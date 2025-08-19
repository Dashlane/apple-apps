import CoreLocalization
import CorePremium
import SwiftUI

public struct NewPaywallContent {
  let banner: Image
  let headline: String?
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
  public init?(capability: CapabilityKey, premiumStatusProvider: PremiumStatusProvider) {
    switch capability {
    case .secureWiFi:
      self.banner = Image(.hotspot)
      self.headline = nil
      self.title = CoreL10n.paywallsVPNTitle
      self.features = capability.paywallFeatures
      self.link = URL(string: "_").map({ url in
        Link(label: CoreL10n.paywallsVPNLink, url: url)
      })
    case .securityBreach:
      self.banner = Image(.pushIllustration)
      self.headline = nil
      self.title = CoreL10n.paywallsDWMTitle
      self.features = capability.paywallFeatures
      self.link = nil
    default:
      return nil
    }
  }
}

extension CapabilityKey {

  var paywallFeatures: [NewPaywallContent.Feature] {
    switch self {
    case .secureWiFi:
      return [
        .init(asset: .ds.feature.vpn.outlined, description: CoreL10n.paywallsVPNHotspot),
        .init(asset: .ds.healthPositive.outlined, description: CoreL10n.paywallsVPNEncryption),
        .init(asset: .ds.web.outlined, description: CoreL10n.paywallsVPNLocations),
      ]
    case .securityBreach:
      return [
        .init(
          asset: .ds.feature.darkWebMonitoring.outlined,
          description: CoreL10n.paywallsDWMWebScanning),
        .init(asset: .ds.notification.outlined, description: CoreL10n.paywallsDWMAlerts),
        .init(asset: .ds.unlock.outlined, description: CoreL10n.paywallsDWMSecure),
      ]
    default:
      return []
    }
  }

}
