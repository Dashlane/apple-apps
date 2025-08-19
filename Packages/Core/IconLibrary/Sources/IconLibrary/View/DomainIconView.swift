import CoreTypes
import DesignSystem
import SwiftUI

public struct DomainIconView<Accessory: View>: View {
  let model: DomainIconViewModel
  let accessory: Accessory

  public init(
    model: DomainIconViewModel,
    @ViewBuilder accessory: @escaping () -> Accessory
  ) {
    self.model = model
    self.accessory = accessory()
  }

  public var body: some View {
    AsyncIconView { [model] in
      try await model.icon()
    } content: { image, color in
      DS.Thumbnail.login(image)
        .foregroundStyle(color ?? Color.ds.container.decorative.grey)
    }
    .overlay(alignment: .bottomTrailing) {
      accessory
    }
    .id(model.domain?.name)
  }
}

extension DomainIconView where Accessory == EmptyView {
  public init(model: DomainIconViewModel) {
    self.model = model
    self.accessory = EmptyView()
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
      iconLibrary: FakeDomainIconLibrary(icon: Icon(image: .init(systemName: "paperplane.fill")))
    )
  }
}

#Preview {
  DomainIconView(model: .preview)
}
