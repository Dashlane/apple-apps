import SwiftUI
import CoreSync

struct ActionableFieldModifier: ViewModifier {
    let title: String
    let showButton: Bool
    let action: () -> Void

    init(title: String,
         showButton: Bool = true,
         action: @escaping () -> Void) {
        self.title = title
        self.showButton = showButton
        self.action = action
    }

    @Environment(\.detailMode)
    var detailMode

    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 4) {
            content
            if detailMode == .viewing && showButton {
                Spacer()
                Button(action: action, title: title)
                    .accentColor(FiberAsset.accentColor.swiftUIColor)
            }
        }
    }
}

extension View {
        func action(_ title: String,
                showButton: Bool = true,
                action: @escaping () -> Void) -> some View {
        return modifier(ActionableFieldModifier(title: title, showButton: showButton, action: action))
    }

}

extension TextDetailField {

        func copyAction(accessControlHandler: AccessControlProtocol? = nil) -> some View {
        self.modifier(CopiableFieldWithFeedBackModifier(message: L10n.Localizable.kwCopied,
                                                        accessControlHandler: accessControlHandler,
                                                        showButton: !text.isEmpty,
                                                        action: {
                                                            UIPasteboard.general.string = self.text
        }))
    }

    func openAction() -> some View {
        self.modifier(ActionableFieldModifier(title: L10n.Localizable.kwOpen,
                                              showButton: !text.isEmpty,
                                              action: {
                                                let openableUrl = PersonalDataURL(rawValue: self.text).openableUrl
                                                if let url = URL(string: openableUrl) {
                                                    DispatchQueue.main.async {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
        }))
    }
}

extension TOTPDetailField {
        func copyAction(accessControlHandler: AccessControlProtocol? = nil) -> some View {
        self.modifier(CopiableFieldWithFeedBackModifier(message: L10n.Localizable.kwCopied,
                                                        accessControlHandler: accessControlHandler,
                                                        showButton: !secret.isEmpty,
                                                        action: { UIPasteboard.general.string = self.code }))
    }
}

extension SecureDetailField {
        func copyAction(limited: Bool = false, accessControlHandler: AccessControlProtocol? = nil) -> some View {
        self.modifier(CopiableFieldWithFeedBackModifier(message: L10n.Localizable.kwCopied,
                                                   accessControlHandler: accessControlHandler,
                                                   showButton: !(text.isEmpty || limited),
                                                   action: {
                                                    UIPasteboard.general.string = self.text
        }))
    }
}

struct ActionableFieldModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("text")
            .action("action") {

        }
    }
}

extension View {
    func limitedRights(allowViewing: Bool = true,
                       hasInfoButton: Bool = true,
                       shareableItem: ShareableItemProtocol) -> some View {
        Group {
            if  shareableItem.isSharedItem && shareableItem.hasLimitedRights {
                self.modifier(SharingAlertFieldModifier(title: shareableItem.limitedRightsAlertTitle,
                                                        allowViewing: allowViewing,
                                                        hasInfoButton: hasInfoButton))
            } else {
                self
            }
        }
    }
}

struct SharingAlertFieldModifier: ViewModifier {

    @State
    var showAlert: Bool = false

    @Environment(\.detailMode)
    var detailMode

    let title: String
    let allowViewing: Bool
    let hasInfoButton: Bool
    func body(content: Content) -> some View {
        Group {
            if detailMode.isEditing || !allowViewing {
                HStack {
                    content
                        .environment(\.detailMode, .limitedViewing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.showAlert = true
                    }
                    if hasInfoButton {
                        Image(FiberAsset.passwordMissingImage)
                            .foregroundColor(FiberAsset.accentColor.swiftUIColor)
                    }
                }.alert(isPresented: $showAlert) {
                    Alert(title: Text(title))
                }
            } else {
                content
            }
        }

    }
}
