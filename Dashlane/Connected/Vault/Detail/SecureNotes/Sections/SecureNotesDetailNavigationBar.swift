import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit
import CoreLocalization

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
            return Text(CoreLocalization.L10n.Core.kwadddatakwSecureNoteIOS)
        } else if model.mode.isEditing {
            return Text(CoreLocalization.L10n.Core.kwEdit)
        } else {
            return Text("")
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        if model.mode == .updating {
            Button(CoreLocalization.L10n.Core.kwEditClose) {
                withAnimation(.easeInOut) { model.cancel() }
            }
        } else if model.mode.isAdding {
            Button(CoreLocalization.L10n.Core.cancel, action: dismiss)
        } else if navigator()?.canDismiss == true || specificBackButton == .close {
            Button(CoreLocalization.L10n.Core.kwButtonClose, action: dismiss) 
        } else if isPresented || specificBackButton == .back {
            BackButton(color: .ds.text.brand.standard, action: dismiss)
        }
    }

    private var trailingButton: some View {
        Group {
            if model.mode.isEditing {
                Button(CoreLocalization.L10n.Core.kwDoneButton) {
                    withAnimation(.easeInOut) { save() }
                }
                .disabled(!model.canSave)
            } else {
                Button(CoreLocalization.L10n.Core.kwEdit, action: activateEdit)
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
