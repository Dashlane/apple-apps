import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CoreSharing
import DesignSystem
import SwiftUI
import UIDelight
import UserTrackingFoundation
import VaultKit

struct QuickActionsMenuView: View {

  @StateObject
  var model: QuickActionsMenuViewModel

  @State
  private var showLimitedRightsAlert: Bool = false

  @Environment(\.toast)
  private var toast

  @Environment(\.accessControl)
  private var accessControl

  @Environment(\.vaultItemRowCollectionActions)
  private var collectionActions

  @Environment(\.vaultItemRowEditAction)
  private var editAction

  @State
  private var deleteRequest: DeleteVaultItemRequest = .init()

  @State
  private var showSharingDisabledAlert: Bool = false

  @State
  private var showSharing: Bool = false

  @State
  private var showCollectionAddition: Bool = false

  @State
  private var showCollectionRemoval: Bool = false

  init(model: @autoclosure @escaping () -> QuickActionsMenuViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DS.FieldAction.Menu(CoreL10n.kwActions, image: .ds.action.more.outlined) {
      menuButtons
        .onAppear(perform: model.onAppear)
    }
    .alert(
      model.item.limitedRightsAlertTitle,
      isPresented: $showLimitedRightsAlert,
      actions: {
        Button(CoreL10n.kwButtonOk) {}
      }
    )
    .deleteItemAlert(request: $deleteRequest, deleteAction: model.delete)
    .background {
      Rectangle()
        .foregroundStyle(.clear)
        .alert(
          L10n.Localizable.teamSpacesSharingDisabledMessageTitle,
          isPresented: $showSharingDisabledAlert,
          actions: {
            Button(CoreL10n.kwButtonOk) {}
          },
          message: {
            Text(L10n.Localizable.teamSpacesSharingDisabledMessageBody)
          }
        )
    }
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

  @ViewBuilder private var menuButtons: some View {
    copyButton
    editButton
    shareButton
    collectionActionsButtons
    DeleteMenuButton {
      Task {
        deleteRequest.itemDeleteBehavior = try await model.deleteBehaviour()
        deleteRequest.isPresented = true
      }
    }
  }

  private func onCopyAction(_ result: ActionableVaultItemRowViewModel.CopyResult) {
    switch result {
    case .success(let fieldType):
      #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
      #endif
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
  var copyButton: some View {
    if !model.isVaultFrozen {
      VaultItemMenuContent(item: model.item, copy: { model.copy(fieldType: $0, valueToCopy: $1) })
    }
  }
}

extension QuickActionsMenuView {
  @ViewBuilder
  var shareButton: some View {
    if !model.item.hasAttachments && model.item.metadata.isShareable && !model.isVaultFrozen {
      Button {
        if model.sharingDeactivationReason != nil {
          showSharingDisabledAlert = true
        } else {
          accessControl.requestAccess(to: model.item) { access in
            guard access else {
              return
            }
            showSharing = true
          }
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

extension QuickActionsMenuView {
  @ViewBuilder
  fileprivate var editButton: some View {
    if let editAction {
      Button {
        editAction()
      } label: {
        HStack {
          Text(CoreL10n.kwEdit)
          Image.ds.action.edit.outlined
        }
      }
      .disabled(!editAction.isEnabled)
    }
  }
}

extension QuickActionsMenuView {
  @ViewBuilder
  fileprivate var collectionActionsButtons: some View {
    if model.item.metadata.contentType.canBeEmbeddedInCollection && !model.isVaultFrozen {
      ForEach(collectionActions, id: \.id) { collectionAction in
        collectionActionButton(for: collectionAction)
      }
    }
  }

  @ViewBuilder
  private func collectionActionButton(for action: VaultItemRowCollectionActionType) -> some View {
    var shouldBeDisabled: Bool {
      if case .limited = model.item.metadata.sharingPermission,
        case .removeFromThisCollection = action
      {
        return true
      }
      return false
    }
    if !(action == .removeFromACollection && model.itemCollections.isEmpty) {
      Button {
        switch action {
        case .addToACollection:
          accessControl.requestAccess(to: model.item) { success in
            guard success else { return }
            showCollectionAddition = true
          }
        case .removeFromACollection:
          showCollectionRemoval = true
        case .removeFromThisCollection(let action):
          action()
        }
      } label: {
        HStack {
          Text(action.title)
          action.image
        }
      }
      .disabled(shouldBeDisabled)
    }
  }

  fileprivate var collectionAdditionView: some View {
    CollectionAdditionView(
      item: model.item,
      allCollections: model.allVaultCollections.filter(bySpaceId: model.item.spaceId),
      collections: model.unusedCollections
    ) { completion in
      switch completion {
      case .create(let collectionName):
        try? model.addItem(toNewCollectionNamed: collectionName)
        toast(CoreL10n.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
      case .select(let collection):
        try? model.addItem(to: collection)
        toast(CoreL10n.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
      case .cancel:
        break
      }
      showCollectionAddition = false
    }
  }

  fileprivate var collectionRemovalView: some View {
    CollectionsRemovalView(
      collections: model.itemCollections
    ) { completion in
      if case .done(let collectionsRemoved) = completion {
        try? model.removeItem(from: collectionsRemoved)
        toast(CoreL10n.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
      }
      showCollectionRemoval = false
    }
  }
}

extension Definition.Field {
  var pasteboardMessage: String {
    switch self {
    case .password: return L10n.Localizable.pasteboardCopyPassword
    case .email: return L10n.Localizable.pasteboardCopyEmail
    case .login: return L10n.Localizable.pasteboardCopyLogin
    case .secondaryLogin: return L10n.Localizable.pasteboardCopySecondaryLogin
    case .cardNumber: return L10n.Localizable.pasteboardCopyCardNumber
    case .securityCode: return L10n.Localizable.pasteboardCopySecurityCode
    case .iban: return L10n.Localizable.pasteboardCopyIban
    case .bic: return L10n.Localizable.pasteboardCopyBic
    case .number: return L10n.Localizable.pasteboardCopyNumber
    case .fiscalNumber: return L10n.Localizable.pasteboardCopyFiscalNumber
    case .otpCode: return L10n.Localizable.pasteboardCopyOtpCode
    default: return CoreL10n.kwCopied
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
