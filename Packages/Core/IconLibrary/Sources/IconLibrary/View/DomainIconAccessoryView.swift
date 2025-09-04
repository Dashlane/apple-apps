import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
import UIDelight

public struct DomainIconAccessoryView: View {
  let image: Image

  public init(image: Image) {
    self.image = image
  }

  public var body: some View {
    image
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 12, height: 12)
      .foregroundStyle(Color.ds.text.inverse.catchy)
      .padding(1)
      .background(.ds.container.expressive.neutral.catchy.active)
  }
}

#Preview {
  let smallIconModel = DomainIconViewModel(
    domain: Domain(name: "random", publicSuffix: ".org"),
    iconLibrary: FakeDomainIconLibrary(icon: Icon(image: UIImage(systemName: "link.circle.fill")))
  )
  return DomainIconView(
    model: smallIconModel,
    accessory: {
      DomainIconAccessoryView(image: .ds.passkey.filled)
    }
  )
}
