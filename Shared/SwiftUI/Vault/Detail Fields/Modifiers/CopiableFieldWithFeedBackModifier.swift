import Foundation
import SwiftUI

struct CopiableFieldWithFeedBackModifier: ViewModifier {
    let action: () -> Void
    let toast: String
    let accessControlHandler: AccessControlProtocol?
    let showButton: Bool

    @AutoReverseState(autoReverseInterval: 1.5)
    var message: ToastMessage?

    init(message: String,
         accessControlHandler: AccessControlProtocol? = nil,
         showButton: Bool = true,
         action: @escaping () -> Void) {
        self.action = action
        self.toast = message
        self.showButton = showButton
        self.accessControlHandler = accessControlHandler
    }

    func body(content: Content) -> some View {
        content
            .modifier(ActionableFieldModifier(title: L10n.Localizable.kwCopyButton, showButton: showButton, action: {
                guard let accessControl = self.accessControlHandler else {
                    self.action()
                    self.showToastNotification()
                    return
                }
                accessControl.canAccess { result in
                    if result {
                        self.action()
                        self.showToastNotification()
                    }
                }
            })).toast(message)
    }

    func showToastNotification() {
        self.message = ToastMessage(message: self.toast)
    }
}
