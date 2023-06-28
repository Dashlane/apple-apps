import SwiftUI
import CorePersonalData
import UIDelight
import Combine
import CoreUserTracking
import DashlaneAppKit
import VaultKit
import CoreSharing
import CoreFeature
import DesignSystem
import CoreLocalization

struct QuickActionsMenuView: View {

    let model: QuickActionsMenuViewModel

    @State
    private var showLimitedRightsAlert: Bool = false

    @Environment(\.toast)
    private var toast

    @Environment(\.vaultItemRowCollectionActions)
    private var collectionActions

    @Environment(\.vaultItemRowEditAction)
    private var editAction

    @State
    private var deleteRequest: DeleteVaultItemRequest = .init()

    @State
    private var showSharingDisabledAlert: Bool = false

    @State
    private var showSharingFlow: Bool = false

    @State
    private var showSharing: Bool = false

    @State
    private var showCollectionAddition: Bool = false

    @State
    private var showCollectionRemoval: Bool = false

    @FeatureState(.collectionsContainer)
    private var areCollectionsEnabled: Bool

    var body: some View {
        Menu {
            VaultItemMenuContent(item: model.item, copy: model.copy)
            editButton
            shareButton
            if areCollectionsEnabled {
                collectionActionsButtons
            }
            DeleteMenuButton {
                Task {
                    deleteRequest.itemDeleteBehavior = try await model.deleteBehaviour()
                    deleteRequest.isPresented = true
                }
            }
        } label: {
            Image.ds.action.more.outlined
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibility(label: Text(CoreLocalization.L10n.Core.kwActions))
                .frame(width: 24, height: 40)
                .foregroundColor(.ds.text.brand.standard)
                .onReceive(model.copyResultPublisher, perform: onCopyAction)
                .alert(isPresented: $showLimitedRightsAlert) {
                    Alert(title: Text(model.item.limitedRightsAlertTitle))
                }
        }
        .deleteItemAlert(request: $deleteRequest, deleteAction: model.delete)
        .background {
                        Rectangle().foregroundColor(.clear)
                .alert(isPresented: $showSharingDisabledAlert) {
                    Alert(model.sharingDeactivationReason ?? .b2bSharingDisabled)
                }
        }
        .onTapGesture(perform: {
            model.reportAppearance()
        })
        .sheet(isPresented: $showSharing) {
            ShareFlowView(model: self.model.shareFlowViewModelFactory.make(items: [self.model.item]))
        }
        .sheet(isPresented: $showCollectionAddition) {
            collectionAdditionView
        }
        .sheet(isPresented: $showCollectionRemoval) {
            collectionRemovalView
        }
    }

    private func onCopyAction(_ result: VaultItemRowModel.CopyResult) {
        switch result {
        case .success(let fieldType):
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            toast(fieldType.pasteboardMessage, image: .ds.action.copy.outlined)
        case .limitedRights:
            self.showLimitedRightsAlert = true
        case .authenticationDenied:
            break
        }
    }

}

extension QuickActionsMenuView {
        @ViewBuilder
    var shareButton: some View {
        if !model.item.hasAttachments && model.item.metadata.isShareable {
            Button {
                if model.sharingDeactivationReason != nil {
                    showSharingDisabledAlert = true
                } else {
                    showSharing = true
                }
            } label: {
                HStack {
                    Text(L10n.Localizable.shareQuickAction)
                    Image.ds.shared.outlined
                }
            }
        }
    }
}

private extension QuickActionsMenuView {
    @ViewBuilder
    var editButton: some View {
        if let editAction {
            Button {
                editAction()
            } label: {
                HStack {
                    Text(CoreLocalization.L10n.Core.kwEdit)
                    Image.ds.action.edit.outlined
                }
            }
        }
    }
}

private extension QuickActionsMenuView {
    @ViewBuilder
    var collectionActionsButtons: some View {
                if model.item is Credential {
            ForEach(collectionActions, id: \.id) { collectionAction in
                                if collectionAction != .removeFromACollection || !model.itemCollections.isEmpty {
                    Button {
                        switch collectionAction {
                        case .addToACollection:
                            showCollectionAddition = true
                        case .removeFromACollection:
                            showCollectionRemoval = true
                        case .removeFromThisCollection(let action):
                            action()
                        }
                    } label: {
                        HStack {
                            Text(collectionAction.title)
                            collectionAction.image
                        }
                    }
                }
            }
        }
    }

    var collectionAdditionView: some View {
        CollectionAdditionView(
            allCollections: model.allVaultCollections.filter(spaceId: model.item.spaceId),
            collections: model.unusedCollections
        ) { completion in
            if case .done(let collectionName) = completion {
                try? model.addItemToCollection(named: collectionName)
                toast(CoreLocalization.L10n.Core.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
            }
            showCollectionAddition = false
        }
    }

    var collectionRemovalView: some View {
        CollectionsRemovalView(
            collections: model.itemCollections
        ) { completion in
            if case .done(let collectionsRemoved) = completion {
                try? model.removeItem(from: collectionsRemoved)
                toast(CoreLocalization.L10n.Core.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
            }
            showCollectionRemoval = false
        }
    }
}

extension Definition.Field {
    var pasteboardMessage: String {
        switch self {
        case .password:         return L10n.Localizable.pasteboardCopyPassword
        case .email:            return L10n.Localizable.pasteboardCopyEmail
        case .login:            return L10n.Localizable.pasteboardCopyLogin
        case .secondaryLogin:   return L10n.Localizable.pasteboardCopySecondaryLogin
        case .cardNumber:       return L10n.Localizable.pasteboardCopyCardNumber
        case .securityCode:     return L10n.Localizable.pasteboardCopySecurityCode
        case .iban:             return L10n.Localizable.pasteboardCopyIban
        case .bic:              return L10n.Localizable.pasteboardCopyBic
        case .number:           return L10n.Localizable.pasteboardCopyNumber
        case .fiscalNumber:     return L10n.Localizable.pasteboardCopyFiscalNumber
        case .otpCode:          return L10n.Localizable.pasteboardCopyOtpCode
        default: return CoreLocalization.L10n.Core.kwCopied
        }
    }
}

struct QuickActionsMenuView_Previews: PreviewProvider {
    private static var company: Company {
        var company = Company()
        company.name = "blabalbal"
        company.jobTitle = "android dev"
        return company
    }

    static var previews: some View {
        MultiContextPreview {
            QuickActionsMenuView(model: .mock(item: company))
                .background(Color.ds.container.agnostic.neutral.supershy)
        }
        .previewLayout(.sizeThatFits)
    }
}
