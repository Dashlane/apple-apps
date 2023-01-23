import CorePersonalData
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import UIKit
import CoreFeature

struct SecureNotesDetailToolbar: View {

    @Environment(\.dismiss)
    private var dismissAction

    @Environment(\.isPresented)
    private var isPresented

    @Environment(\.navigator)
    private var navigator

    @Environment(\.detailContainerViewSpecificDismiss)
    private var dismissView

    @ObservedObject
    var model: SecureNotesDetailToolbarModel

    let toolbarHeight: CGFloat

    var isEditingContent: FocusState<Bool>.Binding

    @Binding
    var showDocumentStorage: Bool

    @Binding
    var showColorPicker: Bool

    @Binding
    var showSpaceSelector: Bool

    @State
    private var showLimitedRightsAlert: Bool = false

    @State
    private var showToolsActionSheet: Bool = false

    @State
    private var showSharingDisabledAlert: Bool = false

    @State
    private var deleteRequest: DeleteVaultItemRequest = .init()

    @Environment(\.toast)
    private var toast

    var body: some View {
        if !isEditingContent.wrappedValue {
            VStack(spacing: 0) {
                Divider()
                    .foregroundColor(.ds.border.neutral.quiet.idle)
                HStack {
                    if !model.mode.isAdding {
                        Spacer()
                            .alert(item: $model.alert) { alert in
                                switch alert {
                                case .errorWhileDeletingFiles:
                                    return Alert(title: Text(L10n.Localizable.kwExtSomethingWentWrong),
                                                 dismissButton: Alert.Button.default(Text(L10n.Localizable.kwButtonOk)))
                                }
                            }
                        deleteButton
                    }
                    Spacer()
                    if !model.mode.isAdding && !model.item.hasAttachments {
                        shareButton
                        Spacer()
                    }
                    if model.shouldShowLockButton {
                        lockButton
                        Spacer()
                    }
                    if !model.mode.isAdding && !model.item.isShared {
                        documentStorageButton
                        Spacer()
                    }
                    toolsButton
                    Spacer()

                    if model.availableUserSpaces.count > 1 {
                        spaceButton
                        Spacer()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: toolbarHeight)
            }
            .background(Color.ds.container.agnostic.neutral.quiet.edgesIgnoringSafeArea(.bottom))
        }
    }

        private var deleteButton: some View {
        Button(action: {
            Task {
                deleteRequest.itemDeleteBehavior = try await model.itemDeleteBehavior()
                deleteRequest.isPresented = true
            }
        }, label: {
            Image.ds.action.delete.outlined
                .foregroundColor(.ds.text.danger.standard)
                .aspectRatio(contentMode: .fit)
        })
        .deleteItemAlert(request: $deleteRequest, deleteAction: delete)
        .accessibilityLabel(L10n.Localizable.kwDelete)
    }

        private var lockMessage: String {
        model.item.secured ? L10n.Localizable.kwPadNotesLockedNotice : L10n.Localizable.kwPadNotesUnlockedNotice
    }

    private var lockIcon: SwiftUI.Image {
        model.item.secured ? .ds.lock.outlined : .ds.unlock.outlined
    }

    private var lockButton: some View {
        Button(action: {
            guard !model.hasLimitedRights else {
                showLimitedRightsAlert = true
                return
            }
            model.item.secured.toggle()
            model.logger.lockUsageLog(secured: model.item.secured)
            model.saveIfViewing()
            toast(lockMessage, image: .ds.secureLock(locked: model.item.secured))
            UISelectionFeedbackGenerator().selectionChanged()
        }, label: {
            lockIcon
                .foregroundColor(.ds.text.neutral.quiet)
        })
        .frame(minWidth: 18)
        .accessibilityLabel(model.item.secured ? L10n.Localizable.accessibilitySecureNoteUnlock : L10n.Localizable.accessibilitySecureNoteLock)
        .alert(isPresented: $showLimitedRightsAlert) {
            Alert(title: Text(model.item.limitedRightsAlertTitle))
        }
    }

        @ViewBuilder
    private var shareButton: some View {
        ShareButton(model: model.shareButtonViewModelFactory.make(items: [model.item])) {
            Image.ds.action.share.outlined
                .foregroundColor(.ds.text.neutral.quiet)
        }
    }

        private var documentStorageButton: some View {
        Button(action: {
            if !model.mode.isAdding {
                showDocumentStorage = true
            }
        }, label: {
            Image.ds.attachment.outlined
                .foregroundColor(.ds.text.neutral.quiet)
        })
        .accessibilityLabel(Text(L10n.Localizable.kwAttachementsTitle))
    }

        private var toolsButton: some View {
        Button(action: { showToolsActionSheet.toggle() }, label: {
            Image.ds.tools.outlined
                .foregroundColor(.ds.text.neutral.quiet)
        })
        .actionSheet(isPresented: $showToolsActionSheet) {
            ActionSheet(
                title: Text(L10n.Localizable.kwSecureNoteIOS),
                message: nil,
                buttons: [
                    .cancel(),
                    .default(Text(L10n.Localizable.KWSecureNoteIOS.colorTitle), action: { showColorPicker = true })
                ]
            )
        }
        .accessibilityLabel(Text(L10n.Localizable.customizeSecureNote))
    }

        private var spaceButton: some View {
        Button(action: { showSpaceSelector = true }, label: {
            UserSpaceIcon(space: model.selectedUserSpace, size: .normal)
                .equatable()
        })
        .disabled(model.isUserSpaceForced)
    }
}

private extension SecureNotesDetailToolbar {

    func delete() {
        Task {
            await self.model.delete()
            await MainActor.run {
                self.dismiss()
            }
        }
    }

    func dismiss() {
        if let dismissView {
            dismissView()
        } else if let navigator = navigator(), navigator.canDismiss == true {
            navigator.dismiss()
        } else {
            dismissAction()
        }
    }
}

private extension SwiftUI.Image.ds {
    static func secureLock(locked: Bool) -> SwiftUI.Image {
        locked ? .ds.lock.outlined : .ds.unlock.outlined
    }
}
