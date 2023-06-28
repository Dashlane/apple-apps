import SwiftUI
import CoreLocalization

struct RevokeSharingButton: View {
    @Environment(\.revokeAction)
    private var revokeAction

    var body: some View {
        Button(L10n.Localizable.kwRevokeAccess, role: .destructive) {
            revokeAction()
        }
    }
}

extension View {
        func onRevokeSharing(_ action: @escaping () -> Void) -> some View {
        self.modifier(RevokeSharingDialog(action: action))
    }
}

private struct RevokeSharingDialog: ViewModifier {
    let action: () -> Void

    @State
    var showRevokeAlert: Bool = false

    func body(content: Content) -> some View {
        content
            .environment(\.revokeAction, RevokeAction {
                showRevokeAlert = true
            })
            .confirmationDialog(L10n.Localizable.kwRevokeAlertTitle, isPresented: $showRevokeAlert, titleVisibility: .visible) {
                Button(L10n.Localizable.kwRevokeAccess) {
                    action()
                }
                Button(CoreLocalization.L10n.Core.cancel, role: .cancel) {

                }
            } message: {
                Text(L10n.Localizable.kwRevokeAlertMsg)
            }
    }
}

private struct RevokeAction {
    let action: () -> Void
    func callAsFunction() {
        action()
    }
}

private struct RevokeActionKey: EnvironmentKey {
    static var defaultValue: RevokeAction = RevokeAction { }

    static func reduce(value: inout RevokeAction, nextValue: () -> RevokeAction) {
        value = nextValue()
    }
}

private extension EnvironmentValues {
    var revokeAction: RevokeAction {
        get { self[RevokeActionKey.self] }
        set { self[RevokeActionKey.self] = newValue }
    }
}

struct RevokeSharingButton_Previews: PreviewProvider {
    struct TestView: View {
        @State
        var revokeTriggered: Bool = false

        var body: some View {
            VStack {
                if revokeTriggered {
                    Text("Revoked!")
                } else {
                    RevokeSharingButton()

                }
            }.onRevokeSharing {
                revokeTriggered.toggle()
            }
        }
    }
    static var previews: some View {
        TestView()
    }
}
