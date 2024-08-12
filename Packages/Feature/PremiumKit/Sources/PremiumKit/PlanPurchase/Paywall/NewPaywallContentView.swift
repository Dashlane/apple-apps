import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct NewPaywallContentView: View {

  let content: NewPaywallContent

  public var body: some View {
    VStack {
      Image(asset: content.banner)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 214, height: 108)
        .padding(.bottom, 16)

      VStack(alignment: .leading, spacing: 32) {
        Text(content.title)
          .font(.title)

        ForEach(content.features) { feature in
          FeatureLine(feature: feature, size: .default)
        }
        #if canImport(UIKit)
          content.link.map { link in
            Button(link.label) { UIApplication.shared.open(link.url) }
              .buttonStyle(.externalLink)
              .controlSize(.small)
          }
        #endif
      }
    }
  }
}

struct NewPaywallContentView_Previews: PreviewProvider {
  static var vpnContent: NewPaywallContent {
    return NewPaywallContent(
      banner: Asset.hotspot,
      title: L10n.Core.paywallsVPNTitle,
      features: [
        NewPaywallContent.Feature(
          asset: .ds.feature.vpn.outlined, description: L10n.Core.paywallsVPNHotspot),
        NewPaywallContent.Feature(
          asset: .ds.healthPositive.outlined, description: L10n.Core.paywallsVPNEncryption),
        NewPaywallContent.Feature(
          asset: .ds.web.outlined, description: L10n.Core.paywallsVPNLocations),
      ],
      link: URL(string: "_").map({ url in
        NewPaywallContent.Link(label: L10n.Core.paywallsVPNLink, url: url)
      }))
  }

  static var previews: some View {
    MultiContextPreview {
      NewPaywallContentView(content: vpnContent)
    }
  }
}
