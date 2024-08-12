import DashTypes
import DesignSystem
import SwiftUI

public struct DomainIconView<Accessory: View>: View {

  let animate: Bool
  let model: DomainIconViewModel
  let placeholderTitle: String
  let accessory: Accessory

  public init(
    animate: Bool = true,
    model: DomainIconViewModel,
    placeholderTitle: String,
    @ViewBuilder accessory: @escaping () -> Accessory
  ) {
    self.animate = animate
    self.model = model
    self.placeholderTitle = placeholderTitle
    self.accessory = accessory()
  }

  public var body: some View {
    AsyncIconView(animate: animate) {
      try await model.icon()
    } content: { image, colors in
      icon(for: image, colors: colors)
    } placeholder: {
      placeholder
    }
    .id(model.domain?.name ?? placeholderTitle)
  }

  @ViewBuilder
  private var placeholder: some View {
    PlaceholderIconView(title: placeholderTitle, sizeType: model.size)
      .modifier(BorderedIcon(sizeType: model.size))
      .overlay(
        alignment: .bottomTrailing,
        content: {
          accessory
        }
      )
      .modifier(RoundedIcon(sizeType: model.size))
      .compositingGroup()
  }

  @ViewBuilder
  private func icon(for image: Image, colors: IconColorSet?) -> some View {
    let colorSet = colors ?? .placeholderColorSet
    let style = IconStyle(
      backgroundColor: SwiftUI.Color(colorSet.backgroundColor), sizeType: model.size)
    image
      .resizable()
      .aspectRatio(contentMode: .fit)
      .modifier(style)
      .modifier(BorderedIcon(sizeType: model.size, color: borderColor(for: colorSet)))
      .overlay(
        alignment: .bottomTrailing,
        content: {
          accessory
        }
      )
      .modifier(RoundedIcon(sizeType: model.size))
      .compositingGroup()
  }

  private func borderColor(for colorSet: IconColorSet) -> SwiftUI.Color {
    if colorSet.backgroundColor.isBorderRequired() {
      return .ds.border.neutral.quiet.idle
    } else {
      return SwiftUI.Color(colorSet.backgroundColor)
    }
  }
}

extension DomainIconView where Accessory == EmptyView {
  public init(
    animate: Bool = true,
    model: DomainIconViewModel,
    placeholderTitle: String
  ) {
    self.animate = animate
    self.model = model
    self.placeholderTitle = placeholderTitle
    self.accessory = EmptyView()
  }
}

extension IconColorSet {
  static var placeholderColorSet: IconColorSet {
    IconColorSet(
      backgroundColor: .ds.container.agnostic.neutral.standard,
      mainColor: .ds.container.agnostic.neutral.standard,
      fallbackColor: .ds.container.agnostic.neutral.standard
    )
  }
}

public struct DomainIconViewModel {
  let domain: Domain?
  let size: IconSizeType
  let iconLibrary: DomainIconLibraryProtocol

  public init(domain: Domain?, size: IconSizeType, iconLibrary: DomainIconLibraryProtocol) {
    self.domain = domain
    self.size = size
    self.iconLibrary = iconLibrary
  }

  func icon() async throws -> Icon? {
    guard let domain = domain else {
      return nil
    }

    return try await iconLibrary.icon(
      for: domain, format: .iOS(large: size == .large || size == .prefilledCredential))
  }
}

extension DomainIconViewModel {
  public static func makeMock(domain: Domain?, size: IconSizeType) -> DomainIconViewModel {
    DomainIconViewModel(domain: domain, size: size, iconLibrary: FakeDomainIconLibrary(icon: nil))
  }
}

struct DomainIconView_Previews: PreviewProvider {
  static let placeholder = Text("placeholder")
  static var previews: some View {
    Group {
      let smallIconModel = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image)))
      DomainIconView(
        model: smallIconModel,
        placeholderTitle: "as"
      )
      .previewDisplayName("Small")

      let largeIconModel = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image)))
      DomainIconView(
        model: largeIconModel,
        placeholderTitle: "as"
      )
      .previewDisplayName("Large")

      let colors = IconColorSet(backgroundColor: .red, mainColor: .red, fallbackColor: .red)

      let modelWithColors = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image, colors: colors)))
      DomainIconView(
        model: modelWithColors,
        placeholderTitle: "as"
      )
      .previewDisplayName("Background Colors")

      let modelWithoutIcon = DomainIconViewModel(
        domain: Domain(name: "random", publicSuffix: ".org"),
        size: .small,
        iconLibrary: FakeDomainIconLibrary(icon: nil))
      DomainIconView(
        model: modelWithoutIcon,
        placeholderTitle: "as"
      )
      .previewDisplayName("Placeholder")
    }
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
