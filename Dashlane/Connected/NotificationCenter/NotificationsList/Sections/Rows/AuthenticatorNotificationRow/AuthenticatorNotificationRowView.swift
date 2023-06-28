import Foundation
import SwiftUI

struct AuthenticatorNotificationRowView: View {
    let model: AuthenticatorNotificationRowViewModel

    var body: some View {
        BaseNotificationRowView(icon: model.notification.icon,
                                title: model.notification.title,
                                description: model.notification.description,
                                accessibilityDescription: L10n.Localizable.authenticatorToolOnboardingActionItemDescriptionAccessibility) {
            model.openAuthenticator()
        }
    }
}

struct AuthenticatorNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AuthenticatorNotificationRowView(model: AuthenticatorNotificationRowViewModel.mock)
        }
    }
}
