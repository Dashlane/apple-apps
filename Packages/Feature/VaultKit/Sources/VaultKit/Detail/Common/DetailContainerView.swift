#if os(iOS)
import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import DocumentServices
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct DetailContainerView<Content: View, Item: VaultItem & Equatable>: View, DismissibleDetailView {
    @ObservedObject
    var model: DetailContainerViewModel<Item>

    @Environment(\.dismiss)
    public var dismissAction

    @Environment(\.navigator)
    public var navigator

    @Environment(\.detailContainerViewSpecificDismiss)
    public var dismissView

    @Environment(\.isPresented)
    private var isPresented

    @Environment(\.detailContainerViewSpecificSave)
    var specificSave

    @Environment(\.detailContainerViewSpecificBackButton)
    var specificBackButton

    @State
    var titleHeight: CGFloat? = DetailDimension.defaultNavigationBarHeight 

    @State
    var showSpaceSelector: Bool = false

    @State
    var showCancelConfirmationDialog: Bool = false

    @State
    var deleteRequest: DeleteVaultItemRequest = .init()

    @Environment(\.toast)
    var toast

    @FeatureState(ControlledFeature.documentStorageAllItems)
    var isDocumentStorageAllItemsEnabled: Bool

    @FeatureState(ControlledFeature.documentStorageIds)
    var isDocumentStorageIdsEnabled: Bool

    let content: Content

    public init(
        service: DetailService<Item>,
        @ViewBuilder content: () -> Content
    ) {
        self.model = .init(service: service)
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            list
                .editionDisabled(!model.mode.isEditing)
                .textFieldDisabledEditionAppearance(.discrete)
                .overlay(loadingView)
                .onReceive(model.eventPublisher) { event in
                    switch event {
                    case .copy(let success):
                        onCopyAction(success)
                    case .cancel:
                        showCancelConfirmationDialog = true
                    default:
                        event.toastMessage.map { toast($0, image: event.toastIcon) }
                    }
                }

            navigationBar
        }
        .navigationBarBackButtonHidden(true)
        .userActivity(.viewItem, isActive: model.advertiseUserActivity) { activity in
            activity.update(with: model.item)
        }
        .onAppear(perform: self.model.reportDetailViewAppearance)
        .makeShortcuts(model: model,
                       edit: { self.model.mode = .updating },
                       save: { self.save() },
                       cancel: { self.model.mode = .viewing },
                       close: { self.dismiss() },
                       delete: askDelete)
        .confirmationDialog(
            L10n.Core.KWVaultItem.UnsavedChanges.title,
            isPresented: $showCancelConfirmationDialog,
            titleVisibility: .visible,
            actions: {
                Button(L10n.Core.KWVaultItem.UnsavedChanges.leave, role: .destructive) { model.confirmCancel() }
                Button(L10n.Core.KWVaultItem.UnsavedChanges.keepEditing, role: .cancel) { }
            },
            message: {
                Text(L10n.Core.KWVaultItem.UnsavedChanges.message)
            }
        )
    }

    private var list: some View {
        DetailList(offsetEnabled: model.mode == .viewing, titleHeight: $titleHeight) {
            self.content
                .environment(\.detailMode, self.model.mode)

            if model.availableUserSpaces.count > 1 {
                SpaceSelectorSection(
                    selectedUserSpace: model.selectedUserSpace,
                    isUserSpaceForced: model.isUserSpaceForced,
                    showSpaceSelector: $showSpaceSelector
                )
            }

            if shouldShowAttachmentButton {
                AttachmentsSectionView(model: model.makeAttachmentsSectionViewModel())
                    .alert(item: $model.alert) { alert in
                        switch alert {
                        case .errorWhileDeletingFiles:
                            return Alert(title: Text(L10n.Core.kwExtSomethingWentWrong),
                                         dismissButton: Alert.Button.default(Text(L10n.Core.kwButtonOk)))
                        }
                    }
            }

            if model.mode == .viewing || model.mode == .limitedViewing {
                DetailSyncAndDatesSection(item: model.item)
            }

            if self.model.mode == .updating {
                Section {
                    self.deleteButton
                }
            }
        }
        .textFieldAppearance(.grouped)
        .navigation(isActive: $showSpaceSelector) {
            spaceSelectorList
        }
    }

    private var shouldShowAttachmentButton: Bool {
        !self.model.mode.isEditing && isDocumentStorageEnabled && !model.item.isShared
    }

    private var isDocumentStorageEnabled: Bool {
                guard !isDocumentStorageAllItemsEnabled else {
            return true
        }

                return isDocumentStorageIdsEnabled && model.item.enumerated.isId
    }

    @ViewBuilder
    private var loadingView: some View {
        if model.isLoading {
            VStack {
                Spacer()
                ProgressView()
                    .tint(.ds.text.brand.standard)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.ds.container.expressive.neutral.quiet.active)
            .edgesIgnoringSafeArea(.all)
            .fiberAccessibilityElement(children: .combine)
            .fiberAccessibilityLabel(Text(L10n.Core.accessibilityDeletingItem))
        }
    }
}

private extension DetailContainerView {
    var navigationBar: some View {
        NavigationBar(
            leading: self.leadingButton
                .id(self.model.mode),
            title: self.title
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .foregroundColor(.ds.text.neutral.catchy),
            titleAccessory: titleAccessory,
            trailing: self.trailingButton
                .id(self.model.mode),
            height: !model.mode.isEditing ? titleHeight : nil
        )
        .accentColor(.ds.text.brand.standard)
    }

    @ViewBuilder
    var leadingButton: some View {
        if model.mode == .updating {
            Button(L10n.Core.kwEditClose) {
                withAnimation(.easeInOut) {
                    self.model.cancel()
                }
            }
        } else if model.mode.isAdding {
            Button(L10n.Core.cancel, action: dismiss)
        } else if navigator()?.canDismiss == true || specificBackButton == .close {
            Button(L10n.Core.kwButtonClose, action: dismiss) 
        } else if canDismiss || specificBackButton == .back {
            BackButton(color: .ds.text.brand.standard, action: dismiss)
        }
    }

    var navigationBarTitle: Text {
        if self.model.mode.isAdding {
            return Text(model.item.addTitle)
        } else if self.model.mode == .updating {
            return Text(L10n.Core.kwEdit)
        } else {
            return Text(model.item.localizedTitle)
        }
    }

    var canDismiss: Bool {
        return self.model.mode.isAdding || isPresented
    }

    @ViewBuilder
    var title: some View {
        if model.mode == .viewing {
            Text(model.item.localizedTitle)
        } else {
            navigationBarTitle
        }
    }

    var titleAccessory: some View {
        VaultItemIconView(isListStyle: false, model: model.iconViewModel)
            .equatable()
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var trailingButton: some View {
        if model.mode.isEditing {
            Button(L10n.Core.kwSave) {
                withAnimation(.easeInOut) {
                    self.save()
                }
            }
            .disabled(!model.canSave)
        } else {
            Button(L10n.Core.kwEdit) {
                withAnimation(.easeInOut) {
                    self.model.mode = .updating
                }
            }
        }
    }

        var deleteButton: some View {
        Button(L10n.Core.kwDelete, action: askDelete)
            .buttonStyle(DetailRowButtonStyle(.destructive))
            .deleteItemAlert(request: $deleteRequest, deleteAction: delete)
    }

    func askDelete() {
        Task {
            deleteRequest.itemDeleteBehavior = try await model.itemDeleteBehavior()
            deleteRequest.isPresented = true
        }
    }

        var spaceSelectorList: some View {
        SelectionListView(
            selection: Binding(
                get: { model.selectedUserSpace },
                set: { space in model.selectedUserSpace = space }
            ),
            items: model.availableUserSpaces,
            selectionDidChange: model.saveIfViewing
        )
        .buttonStyle(ColoredButtonStyle(color: .ds.text.neutral.catchy))
        .navigationTitle(L10n.Core.KWAuthentifiantIOS.spaceId)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailContainerView_Previews: PreviewProvider {
    static let credential: Credential = {
       var amazon = PersonalDataMock.Credentials.amazon
        amazon.creationDatetime = Date().substract(days: 30)
        amazon.userModificationDatetime = Date().substract(days: 2)
        return amazon
    }()

    static var previews: some View {
        MultiContextPreview {
            DetailContainerView(service: .mock(item: credential, mode: .viewing)) {
                Section {
                    Text("Content")
                }
            }
            DetailContainerView(service: .mock(item: credential, mode: .updating)) {
                Section {
                    Text("Content")
                }
            }
        }
    }
}

fileprivate extension VaultItemEnumeration {
    var isId: Bool {
        switch self {
        case .drivingLicence,
                .idCard,
                .passport,
                .socialSecurityInformation,
                .fiscalInformation:
            return true
        default:
            return false
        }
    }
}

private extension DetailServiceEvent {
    var toastMessage: String? {
        switch self {
        case .domainsUpdate:
            return L10n.Core.KWAuthentifiantIOS.Domains.update
        case .save:
            return L10n.Core.KWVaultItem.Changes.saved
        case .cancel, .copy:
            return nil
        }
    }

    var toastIcon: Image? {
        switch self {
        case .copy:
            return .ds.action.copy.outlined
        case .save, .domainsUpdate:
            return .ds.feedback.success.outlined
        case .cancel:
            return nil
        }
    }
}
#endif
