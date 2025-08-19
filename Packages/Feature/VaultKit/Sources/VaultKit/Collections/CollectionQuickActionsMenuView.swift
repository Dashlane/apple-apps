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
        .accessibility(label: Text(CoreL10n.kwActions))
        .frame(width: 24, height: 40)
        .foregroundStyle(Color.ds.text.brand.standard)
    }
    .toasterOn()
    .onTapGesture {
      viewModel.reportAppearance()
    }
    .sheet(isPresented: $showEdit) {
      CollectionNamingView(viewModel: viewModel.makeEditableCollectionNamingViewModel()) {
        completion in
        if case .done(let collection) = completion {
          viewModel.collection = collection
        }
        showEdit = false
      }
    }
    .confirmationDialog(
      CoreL10n.KWVaultItem.Collections.DeleteAlert.title,
      isPresented: $showDelete,
      titleVisibility: .visible,
      actions: {
        Button(CoreL10n.kwDelete, role: .destructive) { viewModel.deleteCollection(with: toast) }
      },
      message: {
        Text(CoreL10n.KWVaultItem.Collections.DeleteAlert.message)
      }
    )
    .alert(isPresented: $viewModel.showSharedCollectionErrorMessage) {
      Alert(
        title: Text(CoreL10n.KWVaultItem.Collections.DeleteAlert.Error.Shared.title),
        message: Text(CoreL10n.KWVaultItem.Collections.DeleteAlert.Error.Shared.message),
        dismissButton: .default(Text(CoreL10n.kwButtonOk))
      )
    }
    .alert(
      CoreL10n.teamSpacesSharingCollectionsDisabledMessageTitle,
      isPresented: $showSharingDisabledAlert,
      actions: {
        Button(CoreL10n.kwButtonOk) {}
      },
      message: {
        Text(CoreL10n.teamSpacesSharingCollectionsDisabledMessageBody)
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
          Text(CoreL10n.kwEdit)
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
          Text(CoreL10n.kwDelete)
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
          Text(CoreL10n.kwShare)
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
          Text(CoreL10n.kwSharedAccess)
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
