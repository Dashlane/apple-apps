import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct SecureNotesDetailNavigationBar: View, DismissibleDetailView {

    @Environment(\.dismiss)
    var dismissAction

    @Environment(\.isPresented)
    private var isPresented

    @Environment(\.navigator)
    var navigator

    @Environment(\.detailContainerViewSpecificDismiss)
    var dismissView

    @Environment(\.detailContainerViewSpecificBackButton)
    var specificBackButton

    @ObservedObject
    var model: SecureNotesDetailNavigationBarModel

    var body: some View {
        NavigationBar(
            leading: leadingButton.id(model.mode),
            title: navigationTitle.id(model.mode),
            trailing: (!model.hasLimitedRights && model.canEdit ? trailingButton : nil).id(model.mode)
        )
        .accentColor(.ds.text.brand.standard)
        .foregroundColor(.ds.text.brand.standard)
        .onTapGesture { UIApplication.shared.endEditing() }
    }

    private var navigationTitle: Text {
        if model.mode.isAdding {
            return Text(L10n.Localizable.kwadddatakwSecureNoteIOS)
        } else if model.mode.isEditing {
            return Text(L10n.Localizable.kwEdit)
        } else {
            return Text("")
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        if model.mode == .updating {
            Button(L10n.Localizable.kwEditClose) {
                withAnimation(.easeInOut) { model.cancel() }
            }
        } else if model.mode.isAdding {
            Button(L10n.Localizable.cancel, action: dismiss)
        } else if navigator()?.canDismiss == true || specificBackButton == .close {
            Button(L10n.Localizable.kwButtonClose, action: dismiss) 
        } else if isPresented || specificBackButton == .back {
            BackButton(color: .ds.text.brand.standard, action: dismiss)
        }
    }

    private var trailingButton: some View {
        Group {
            if model.mode.isEditing {
                Button(L10n.Localizable.kwDoneButton) {
                    withAnimation(.easeInOut) { save() }
                }
                .disabled(!model.canSave)
            } else {
                Button(L10n.Localizable.kwEdit, action: activateEdit)
            }
        }
    }
}

private extension SecureNotesDetailNavigationBar {

    func save() {
        model.save()
        if model.mode.isAdding && Device.isIpadOrMac {
            navigator()?.dismiss()
            model.showInVault()
        } else {
            model.mode = .viewing
        }
    }

    func activateEdit() {
        withAnimation(.easeInOut) {
            self.model.mode = .updating
            self.model.isEditingContent.wrappedValue = true
        }
    }
}
