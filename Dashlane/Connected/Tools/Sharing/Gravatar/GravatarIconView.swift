import CoreTypes
import DesignSystem
import IconLibrary
import SwiftUI
import VaultKit

struct GravatarIconView: View {
  let model: GravatarIconViewModel
  let isLarge: Bool
  let backgroundColor: Color?

  @State private var image: Image?

  init(model: GravatarIconViewModel, isLarge: Bool = false, backgroundColor: Color? = nil) {
    self.model = model
    self.isLarge = isLarge
    self.backgroundColor = backgroundColor
  }

  var body: some View {
    Thumbnail.User.single(image)
      .task {
        image = (try? await model.icon()?.image).flatMap(Image.init(uiImage:))
      }
      .id(model.email)
      .controlSize(isLarge ? .large : .regular)
  }
}

struct GravatarIconViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {
  let email: String
  let iconLibrary: GravatarIconLibraryProtocol

  init(email: String, iconLibrary: GravatarIconLibraryProtocol) {
    self.email = email
    self.iconLibrary = iconLibrary
  }

  init(email: String, iconService: IconServiceProtocol) {
    self.email = email
    self.iconLibrary = iconService.gravatar
  }

  func icon() async throws -> Icon? {
    return try await iconLibrary.icon(forEmail: email)
  }
}

extension GravatarIconViewModel {
  static func mock(email: String) -> GravatarIconViewModel {
    return GravatarIconViewModel(
      email: email,
      iconLibrary: FakeGravatarIconLibrary(icon: nil)
    )
  }
}

struct GravatarIconView_Previews: PreviewProvider {
  static var previews: some View {
    GravatarIconView(
      model: GravatarIconViewModel(
        email: "_",
        iconService: IconServiceMock()
      ),
      isLarge: false
    )
    .previewDisplayName("Placeholder small")

    GravatarIconView(
      model: GravatarIconViewModel(
        email: "_",
        iconService: IconServiceMock()
      ),
      isLarge: true
    )
    .previewDisplayName("Placeholder large")
  }
}
