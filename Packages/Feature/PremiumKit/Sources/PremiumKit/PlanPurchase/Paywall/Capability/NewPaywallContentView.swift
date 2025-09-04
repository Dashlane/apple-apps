import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct NewPaywallContentView: View {

  let content: NewPaywallContent

  public var body: some View {
    ScrollView {
      VStack {
        content.banner
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.bottom, 16)

        VStack(alignment: .leading, spacing: 16) {
          if let headline = content.headline {
            Text(headline)
              .textStyle(.body.standard.regular)
              .foregroundStyle(Color.ds.text.neutral.quiet)
          }

          Text(content.title)
            .foregroundStyle(Color.ds.text.neutral.catchy)
            .font(.title)

          ForEach(content.features) { feature in
            FeatureLine(feature: feature, size: .default)
          }
          .padding(.top, 16)

          content.link.map { link in
            Button(link.label) { UIApplication.shared.open(link.url) }
              .buttonStyle(.externalLink)
              .controlSize(.small)
          }
          .padding(.vertical, 32)
        }
      }
    }
  }
}

#Preview {
  let vpnContent = NewPaywallContent(
    banner: Image(.hotspot),
    headline: nil,
    title: CoreL10n.paywallsVPNTitle,
    features: [
      NewPaywallContent.Feature(
        asset: .ds.feature.vpn.outlined, description: CoreL10n.paywallsVPNHotspot),
      NewPaywallContent.Feature(
        asset: .ds.healthPositive.outlined, description: CoreL10n.paywallsVPNEncryption),
      NewPaywallContent.Feature(
        asset: .ds.web.outlined, description: CoreL10n.paywallsVPNLocations),
    ],
    link: URL(string: "_").map({ url in
      NewPaywallContent.Link(label: CoreL10n.paywallsVPNLink, url: url)
    })
  )

  NewPaywallContentView(content: vpnContent)
}
