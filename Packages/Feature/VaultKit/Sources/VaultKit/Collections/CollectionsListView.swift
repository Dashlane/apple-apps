import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreUserTracking
import DesignSystem
import SwiftUI
import UIComponents

public struct CollectionsListView: View {

  public enum Action {
    case selected(VaultCollection)
    case share(VaultCollection)
    case changeSharingAccess(VaultCollection)
  }

  @StateObject
  private var viewModel: CollectionsListViewModel

  @Environment(\.toast)
  var toast

  private let action: (Action) -> Void

  @State
  private var showAddition: Bool = false

  @State
  private var collectionToEdit: VaultCollection?

  @State
  private var showDelete: Bool = false

  @State
  private var collectionToDelete: VaultCollection?

  @State
  private var showSharingDisabledAlert: Bool = false

  @State
  private var showStarterLimitationAlert: Bool = false

  public init(
    viewModel: @autoclosure @escaping () -> CollectionsListViewModel,
    action: @escaping (Action) -> Void = { _ in }
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  public var body: some View {
    content
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .navigationBarTitle(L10n.Core.KWVaultItem.Collections.toolsTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toasterOn()
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(
            action: {
              if viewModel.isAdditionRestrictedByFrozenAccount {
                viewModel.redirectToFrozenPaywall()
              } else {
                showAddition = true
              }
            },
            label: {
              Image.ds.action.add.outlined
                .foregroundColor(.ds.text.brand.standard)
            }
          )
        }
      }
      .sheet(isPresented: $showAddition) {
        CollectionNamingView(viewModel: viewModel.makeCollectionNamingViewModel()) { _ in
          showAddition = false
        }
      }
      .sheet(item: $collectionToEdit) { collection in
        CollectionNamingView(viewModel: viewModel.makeCollectionNamingViewModel(for: collection)) {
          _ in
          collectionToEdit = nil
        }
      }
      .reportPageAppearance(.collectionList)
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.collections.isEmpty {
      emptyState
    } else {
      list
    }
  }

  private var list: some View {
    List(viewModel.collections) { collection in
      CollectionRow(viewModel: viewModel.collectionRowViewModelFactory.make(collection: collection))
        .onTapWithFeedback {
          viewModel.reportCollectionSelection(collection)
          action(.selected(collection))
        }
        .swipeActions(edge: .trailing) {
          deleteSwipeAction(for: collection)
          editSwipeAction(for: collection)
          sharingAccessSwipeAction(for: collection)
          sharingSwipeAction(for: collection)
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .confirmationDialog(
      L10n.Core.KWVaultItem.Collections.DeleteAlert.title,
      isPresented: $showDelete,
      presenting: collectionToDelete,
      actions: { collectionToDelete in
        Button(L10n.Core.kwDelete, role: .destructive) {
          viewModel.delete(collectionToDelete, with: toast)
        }
        Button(L10n.Core.cancel, role: .cancel) {}
      },
      message: { _ in
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
    .alert(isPresented: $showStarterLimitationAlert) {
      Alert(
        title: Text(CoreLocalization.L10n.Core.starterLimitationUserSharingUnavailableTitle),
        message: Text(
          CoreLocalization.L10n.Core.starterLimitationUserSharingUnavailableDescription),
        dismissButton: .default(
          Text(CoreLocalization.L10n.Core.starterLimitationUserSharingUnavailableButton))
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
    .scrollContentBackground(.hidden)
  }

  @ViewBuilder
  private func deleteSwipeAction(for collection: VaultCollection) -> some View {
    if viewModel.isDeleteableOrEditable(collection) {
      Button {
        collectionToDelete = collection
        showDelete = true
      } label: {
        Label(L10n.Core.kwDelete, systemImage: "trash.fill")
          .labelStyle(.titleAndIcon)
      }
      .tint(.ds.container.expressive.danger.catchy.idle)
    }
  }

  @ViewBuilder
  private func editSwipeAction(for collection: VaultCollection) -> some View {
    if viewModel.isDeleteableOrEditable(collection) {
      Button {
        collectionToEdit = collection
      } label: {
        Label(L10n.Core.kwEdit, systemImage: "square.and.pencil")
      }
      .tint(.ds.container.expressive.neutral.catchy.idle)
    }
  }

  @ViewBuilder
  private func sharingAccessSwipeAction(for collection: VaultCollection) -> some View {
    if collection.isShared {
      Button(
        action: {
          action(.changeSharingAccess(collection))
        },
        label: {
          Label {
            Text(L10n.Core.kwSharedAccess)
          } icon: {
            Image.ds.shared.filled
          }
          .labelStyle(.titleAndIcon)
        }
      )
      .tint(.ds.container.expressive.brand.catchy.active)
      .disabled(collection.sharingPermission == .limited)
    }
  }

  @ViewBuilder
  private func sharingSwipeAction(for collection: VaultCollection) -> some View {
    Button {
      if viewModel.isSharingDisabledForStarterUser {
        showStarterLimitationAlert = true
      } else if viewModel.isSharingDisabled {
        showSharingDisabledAlert = true
      } else {
        action(.share(collection))
      }
    } label: {
      Label(L10n.Core.kwShare, systemImage: "arrowshape.turn.up.forward.fill")
        .labelStyle(.titleAndIcon)
    }
    .tint(.ds.container.expressive.neutral.catchy.active)
    .disabled(!viewModel.shouldDisplayShareOption(for: collection))
  }

  private var emptyState: some View {
    VStack {
      Image.ds.folder.outlined
        .resizable()
        .frame(width: 96, height: 96)
        .foregroundColor(.ds.text.neutral.quiet)

      Text(L10n.Core.KWVaultItem.Collections.List.EmptyState.message)
        .font(.body)
        .foregroundColor(.ds.text.neutral.quiet)
        .multilineTextAlignment(.center)

      Button(
        action: {
          if viewModel.vaultState == .frozen {
            viewModel.redirectToFrozenPaywall()
          } else {
            showAddition = true
          }
        },
        label: {
          Label(
            L10n.Core.KWVaultItem.Collections.List.EmptyState.button,
            icon: .ds.action.add.outlined
          )
        }
      )
      .buttonStyle(.designSystem(.iconLeading))
      .style(mood: .brand, intensity: .catchy)
      .padding(.vertical, 16)
    }
    .padding(.horizontal, 24)
  }
}

struct CollectionsListView_Previews: PreviewProvider {
  static var previews: some View {
    CollectionsListView(viewModel: .mock)
  }
}
