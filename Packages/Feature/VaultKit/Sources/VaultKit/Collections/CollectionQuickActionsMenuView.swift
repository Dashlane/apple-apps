import CoreFeature
import CoreLocalization
import CorePremium
import DesignSystem
import SwiftUI

public struct CollectionQuickActionsMenuView: View {

  public enum Action {
    case share(VaultCollection)
    case changeSharingAccess(VaultCollection)
  }

  @CapabilityState(.collectionSharing)
  private var collectionSharingCapability

  @StateObject
  var viewModel: CollectionQuickActionsMenuViewModel

  @Environment(\.toast)
  var toast

  @State
  private var showEdit: Bool = false

  @State
  private var showDelete: Bool = false

  @State
  private var showSharingDisabledAlert: Bool = false

  private let action: (Action) -> Void

  public init(
    viewModel: @autoclosure @escaping () -> CollectionQuickActionsMenuViewModel,
    action: @escaping (Action) -> Void = { _ in }
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  public var body: some View {
    Menu {
      if !viewModel.collection.belongsToSpace(id: "") {
        shareButton
      }
      if viewModel.collection.isShared {
        sharedAccessButton
      }
      editButton
      deleteButton
    } label: {
      Image.ds.action.moreEmphasized.outlined
        .resizable()
        .aspectRatio(contentMode: .fit)
        .accessibility(label: Text(L10n.Core.kwActions))
        .frame(width: 24, height: 40)
        .foregroundColor(.ds.text.brand.standard)
    }
    .toasterOn()
    .onTapGesture {
      viewModel.reportAppearance()
    }
    .sheet(isPresented: $showEdit) {
      #if canImport(UIKit)
        CollectionNamingView(viewModel: viewModel.makeEditableCollectionNamingViewModel()) {
          completion in
          if case .done(let collection) = completion {
            viewModel.collection = collection
          }
          showEdit = false
        }
      #endif
    }
    .confirmationDialog(
      L10n.Core.KWVaultItem.Collections.DeleteAlert.title,
      isPresented: $showDelete,
      titleVisibility: .visible,
      actions: {
        Button(L10n.Core.kwDelete, role: .destructive) { viewModel.deleteCollection(with: toast) }
      },
      message: {
        Text(L10n.Core.KWVaultItem.Collections.DeleteAlert.message)
      }
    )
    .alert(isPresented: $viewModel.showSharedCollectionErrorMessage) {
      Alert(
        title: Text(L10n.Core.KWVaultItem.Collections.DeleteAlert.Error.Shared.title),
        message: Text(L10n.Core.KWVaultItem.Collections.DeleteAlert.Error.Shared.message),
        dismissButton: .default(Text(L10n.Core.kwButtonOk))
      )
    }
    .alert(
      L10n.Core.teamSpacesSharingCollectionsDisabledMessageTitle,
      isPresented: $showSharingDisabledAlert,
      actions: {
        Button(L10n.Core.kwButtonOk) {}
      },
      message: {
        Text(L10n.Core.teamSpacesSharingCollectionsDisabledMessageBody)
      }
    )
  }

  private var editButton: some View {
    Button(
      action: {
        showEdit = true
      },
      label: {
        HStack {
          Text(L10n.Core.kwEdit)
          Image.ds.action.edit.outlined
        }
      }
    )
    .disabled(!viewModel.isDeleteableOrEditable)
  }

  private var deleteButton: some View {
    Button(
      role: .destructive,
      action: {
        viewModel.reportDeletionAppearance()
        showDelete = true
      },
      label: {
        HStack {
          Text(L10n.Core.kwDelete)
          Image.ds.action.delete.outlined
        }
      }
    )
    .disabled(!viewModel.isDeleteableOrEditable)
  }

  private var shareButton: some View {
    Button(
      action: {
        if viewModel.isSharingDisabled {
          showSharingDisabledAlert = true
        } else {
          action(.share(viewModel.collection))
        }
      },
      label: {
        HStack {
          Text(L10n.Core.kwShare)
          Image.ds.action.share.outlined
        }
      }
    )
    .disabled(
      (viewModel.collection.sharingPermission == .limited
        || !collectionSharingCapability.isAvailable || viewModel.isAdminDisabledByStarterPack)
        && !viewModel.isMemberDisabledByStarterPack)
  }

  private var sharedAccessButton: some View {
    Button(
      action: {
        action(.changeSharingAccess(viewModel.collection))
      },
      label: {
        HStack {
          Text(L10n.Core.kwSharedAccess)
          Image.ds.shared.outlined
        }
      }
    )
    .disabled(viewModel.collection.sharingPermission == .limited)
  }
}

struct CollectionQuickActionsMenuView_Previews: PreviewProvider {
  static var previews: some View {
    CollectionQuickActionsMenuView(
      viewModel: .mock(
        collection: VaultCollection(collection: PersonalDataMock.Collections.business)))
  }
}
