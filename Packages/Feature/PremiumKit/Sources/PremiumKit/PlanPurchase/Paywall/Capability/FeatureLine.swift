import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

public struct FeatureLine: View {

  enum Size {
    case `default`
    case small

    var boxDimension: CGFloat {
      switch self {
      case .default: return 40
      case .small: return 28
      }
    }

    var tickDimension: CGFloat {
      switch self {
      case .default: return 26
      case .small: return 18
      }
    }
  }

  let feature: NewPaywallContent.Feature
  let size: Size

  public var body: some View {
    HStack {
      ZStack {
        Rectangle()
          .frame(width: size.boxDimension, height: size.boxDimension)
          .foregroundStyle(Color.ds.container.expressive.brand.quiet.idle)
          .cornerRadius(8)

        feature.asset
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: size.tickDimension, height: size.tickDimension)
          .foregroundStyle(Color.ds.container.expressive.brand.catchy.hover)
      }

      MarkdownText(feature.description)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .padding(.horizontal, 8)

      Spacer()
    }
  }
}

struct FeatureLine_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      FeatureLine(
        feature: NewPaywallContent.Feature(
          asset: .ds.checkmark.outlined, description: CoreL10n.paywallsDWMSecure), size: .default)

      FeatureLine(
        feature: NewPaywallContent.Feature(
          asset: .ds.checkmark.outlined, description: CoreL10n.paywallsDWMSecure), size: .small)
    }
  }
}
