import SwiftUI
import CorePersonalData
import Combine
import CorePremium
import UIDelight
import DashlaneAppKit
import SwiftTreats
import DocumentServices
import UIComponents
import VaultKit
import CoreFeature
import DesignSystem

private let timestampFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    formatter.unitsStyle = .full
    return formatter
}()

struct DetailContainerView<Content: View, Item: VaultItem & Equatable>: View, DismissibleDetailView {
    @ObservedObject
    var model: DetailContainerViewModel<Item>

    @Environment(\.dismiss)
    var dismissAction

    @Environment(\.isPresented)
    private var isPresented

    @Environment(\.navigator)
    var navigator

    @Environment(\.detailContainerViewSpecificDismiss)
    var dismissView

    @Environment(\.detailContainerViewSpecificSave)
    var specificSave

    @Environment(\.detailContainerViewSpecificBackButton)
    var specificBackButton

    @State
    var titleHeight: CGFloat? = DetailDimension.defaultNavigationBarHeight 

    @State
    var showSpaceSelector: Bool = false

    @State
    var deleteRequest: DeleteVaultItemRequest = .init()

    @Environment(\.toast)
    var toast

    @FeatureState(ControlledFeature.documentStorageAllItems)
    var isDocumentStorageAllItemsEnabled: Bool

    @FeatureState(ControlledFeature.documentStorageIds)
    var isDocumentStorageIdsEnabled: Bool

    let content: Content

    init(
        service: DetailService<Item>,
        @ViewBuilder content: () -> Content
    ) {
        self.model = .init(service: service)
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            list
                .overlay(loadingView)
                .onReceive(model.copySuccessPublisher, perform: onCopyAction)
                .onReceive(model.toastPublisher, perform: { message in
                    toast(message)
                })

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
    }

    private var list: some View {
        DetailList(offsetEnabled: model.mode == .viewing, titleHeight: $titleHeight) {
            self.content
                .environment(\.detailMode, self.model.mode)

            if self.model.availableUserSpaces.count > 1 {
                Section(header: Text(L10n.Localizable.KWAuthentifiantIOS.spaceId.uppercased())) {
                    self.spaceSelector
                }
            }

            if shouldShowAttachmentButton {
                AttachmentsSectionView(model: model.makeAttachmentsSectionViewModel())
                    .alert(item: $model.alert) { alert in
                        switch alert {
                        case .errorWhileDeletingFiles:
                            return Alert(title: Text(L10n.Localizable.kwExtSomethingWentWrong),
                                         dismissButton: Alert.Button.default(Text(L10n.Localizable.kwButtonOk)))
                        }
                    }
            }

            if model.mode == .viewing || model.mode == .limitedViewing {
                self.metadataDates
            }

            if self.model.mode == .updating {
                Section {
                    self.deleteButton
                }
            }
        }
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
            .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityDeletingItem))
        }
    }

    private var updateDateLabel: String {
        return model.item.isShared ? L10n.Localizable.vaultItemModificationDateByYouLabel : L10n.Localizable.vaultItemModificationDateLabel
    }

    private var metadataDates: some View {
        Section {
                        if let creationDate = model.item.creationDatetime {
                Text(localizedTimeAgo(since: creationDate)) .labeled(L10n.Localizable.vaultItemCreationDateLabel)
            }

                        if let modificationDate = self.model.item.userModificationDatetime, modificationDate != model.item.creationDatetime {
                Text(localizedTimeAgo(since: modificationDate)).labeled(updateDateLabel)
            }
        }
    }

    private func localizedTimeAgo(since date: Date) -> String {
        if abs(date.timeIntervalSinceNow) < 60 {
            return L10n.Localizable.securityAlertUnresolvedJustnow
        }
        return timestampFormatter.localizedString(for: date, relativeTo: Date())
    }

        private var spaceSelector: some View {
        Button(action: showSpaceSelectorListView) {
            HStack {
                UserSpaceIcon(space: model.selectedUserSpace, size: .normal).equatable()
                Text(model.selectedUserSpace.teamName)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
        }
        .buttonStyle(DetailRowButtonStyle())
        .disabled(model.isUserSpaceForced)
    }

        private var navigationBar: some View {
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
    private var leadingButton: some View {
        if model.mode == .updating {
            Button(L10n.Localizable.kwEditClose) {
                withAnimation(.easeInOut) {
                    self.model.cancel()
                }
            }
        } else if model.mode.isAdding {
            Button(L10n.Localizable.cancel, action: dismiss)
        } else if navigator()?.canDismiss == true || specificBackButton == .close {
            Button(L10n.Localizable.kwButtonClose, action: dismiss) 
        } else if canDismiss || specificBackButton == .back {
            BackButton(color: .ds.text.brand.standard, action: dismiss)
        }
    }

    private var navigationBarTitle: Text {
        if self.model.mode.isAdding {
            return Text(model.item.addTitle)
        } else if self.model.mode == .updating {
            return Text(L10n.Localizable.kwEdit)
        } else {
            return Text(model.item.localizedTitle)
        }
    }

    private var canDismiss: Bool {
        return self.model.mode.isAdding || isPresented
    }

    @ViewBuilder
    private var title: some View {
        if model.mode == .viewing {
            Text(model.item.localizedTitle)
        } else {
            navigationBarTitle
        }
    }

    private var titleAccessory: some View {
        VaultItemIconView(isListStyle: false, model: model.iconViewModel)
            .equatable()
    }

    @ViewBuilder
    private var trailingButton: some View {
        if model.mode.isEditing {
            Button(L10n.Localizable.kwSave) {
                withAnimation(.easeInOut) {
                    self.save()
                }
            }
            .disabled(!model.canSave)
        } else {
            Button(L10n.Localizable.kwEdit) {
                withAnimation(.easeInOut) {
                    self.model.mode = .updating
                }
            }
        }
    }

        private var deleteButton: some View {
        Button(L10n.Localizable.kwDelete, action: askDelete)
        .buttonStyle(DetailRowButtonStyle(.destructive))
        .deleteItemAlert(request: $deleteRequest, deleteAction: delete)
    }

    func askDelete() {
        Task {
            deleteRequest.itemDeleteBehavior = try await model.itemDeleteBehavior()
            deleteRequest.isPresented = true
        }
    }

        private var spaceSelectorList: some View {
        SelectionListView(
            selection: Binding(
                get: { model.selectedUserSpace },
                set: { space in model.selectedUserSpace = space }
            ),
            items: model.availableUserSpaces,
            selectionDidChange: model.saveIfViewing
        )
        .buttonStyle(ColoredButtonStyle(color: .ds.text.neutral.catchy))
        .navigationTitle(L10n.Localizable.KWAuthentifiantIOS.spaceId)
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
