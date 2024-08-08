import DashTypes
import Foundation
import SwiftUI
import UIDelight

public struct DomainIconAccessoryView: View {
  let image: Image
  let sizeType: IconSizeType

  public init(image: Image, sizeType: IconSizeType) {
    self.image = image
    self.sizeType = sizeType
  }

  public var body: some View {
    image
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 12, height: 12)
      .foregroundColor(.ds.text.inverse.catchy)
      .padding(1)
      .background(.ds.container.expressive.neutral.catchy.active)
      .clipShape(UnevenRoundedRectangle(topLeading: sizeType.radius))
  }
}

struct DomainIconAccessoryView_Previews: PreviewProvider {
  static let placeholder = Text("placeholder")
  static var previews: some View {

    Group {
      let smallIconModel = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image)))
      DomainIconView(
        model: smallIconModel,
        placeholderTitle: "as",
        accessory: {
          DomainIconAccessoryView(image: .ds.passkey.filled, sizeType: .small)
        }
      )
      .previewDisplayName("Small")

      let largeIconModel = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .large,
        iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image)))
      DomainIconView(
        model: largeIconModel,
        placeholderTitle: "as",
        accessory: {
          DomainIconAccessoryView(image: .ds.passkey.filled, sizeType: .large)
        }
      )
      .previewDisplayName("Large")

      let colors = IconColorSet(backgroundColor: .red, mainColor: .red, fallbackColor: .red)

      let modelWithColors = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image, colors: colors)))
      DomainIconView(
        model: modelWithColors,
        placeholderTitle: "as",
        accessory: {
          DomainIconAccessoryView(image: .ds.passkey.filled, sizeType: .small)
        }
      )
      .previewDisplayName("Background Colors")

      let modelWithoutIcon = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: nil))
      DomainIconView(
        model: modelWithoutIcon,
        placeholderTitle: "as",
        accessory: {
          DomainIconAccessoryView(image: .ds.passkey.filled, sizeType: .small)
        }
      )
      .previewDisplayName("Placeholder")
    }

    .padding()
    .previewLayout(.sizeThatFits)
  }
}
