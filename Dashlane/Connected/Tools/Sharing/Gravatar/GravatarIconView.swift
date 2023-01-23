import SwiftUI
import IconLibrary
import DashlaneAppKit
import VaultKit
import DashTypes

struct GravatarIconView: View {

    let model: GravatarIconViewModel
    let isLarge: Bool
    let backgroundColor: SwiftUI.Color?

    init(model: GravatarIconViewModel, isLarge: Bool = false, backgroundColor: SwiftUI.Color? = nil) {
        self.model = model
        self.isLarge = isLarge
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        AsyncIconView {
            try await model.icon()
        } content: { image, _ in
            image
                .resizable()
                .renderingMode(.original)
                .contactsIconStyle(isLarge: isLarge)
        } placeholder: {
            ContactsPlaceholderIconView(title: model.email, isLarge: isLarge, backgroundColor: backgroundColor)
        }
        .id(model.email)
        .accessibilityHidden(true)
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
        return GravatarIconViewModel(email: email, iconLibrary: FakeGravatarIconLibrary(icon: nil))
    }
}

struct GravatarIconView_Previews: PreviewProvider {
    static var previews: some View {
        GravatarIconView(model: GravatarIconViewModel(email: "_", iconService: IconServiceMock()), isLarge: false)
            .previewDisplayName("Placeholder small")

        GravatarIconView(model: GravatarIconViewModel(email: "_", iconService: IconServiceMock()), isLarge: true)
            .previewDisplayName("Placeholder large")
    }
}
