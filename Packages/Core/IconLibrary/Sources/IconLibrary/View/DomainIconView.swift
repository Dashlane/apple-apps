import DashTypes
import DesignSystem
import SwiftUI

public struct DomainIconView<Accessory: View>: View {
  let model: DomainIconViewModel
  let accessory: Accessory
  let isLarge: Bool

  public init(
    model: DomainIconViewModel,
    @ViewBuilder accessory: @escaping () -> Accessory,
    isLarge: Bool = false
  ) {
    self.model = model
    self.accessory = accessory()
    self.isLarge = isLarge
  }

  public var body: some View {
    AsyncIconView { [model] in
      try await model.icon()
    } content: { image, color in
      DS.Thumbnail.login(image)
        .foregroundStyle(color ?? .primary)
        .controlSize(isLarge ? .large : .small)
    }
    .overlay(alignment: .bottomTrailing) {
      accessory
    }
    .id(model.domain?.name)
  }
}

extension DomainIconView where Accessory == EmptyView {
  public init(model: DomainIconViewModel, isLarge: Bool = false) {
    self.model = model
    self.accessory = EmptyView()
    self.isLarge = isLarge
  }
}

public struct DomainIconViewModel: Sendable {
  let domain: Domain?
  let iconLibrary: DomainIconLibraryProtocol

  public init(domain: Domain?, iconLibrary: DomainIconLibraryProtocol) {
    self.domain = domain
    self.iconLibrary = iconLibrary
  }

  func icon() async throws -> Icon? {
    guard let domain = domain else { return nil }
    return try await iconLibrary.icon(for: domain)
  }
}

extension DomainIconViewModel {
  public static func makeMock(domain: Domain?) -> DomainIconViewModel {
    DomainIconViewModel(domain: domain, iconLibrary: FakeDomainIconLibrary(icon: nil))
  }

  static var preview: DomainIconViewModel {
    DomainIconViewModel(
      domain: Domain(name: "random", publicSuffix: ".org"),
      iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image))
    )
  }
}

#Preview {
  DomainIconView(model: .preview)
}
