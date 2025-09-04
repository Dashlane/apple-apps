import CoreLocalization
import CorePremium
import DesignSystem
import SwiftUI

public struct CollectionsListView: View {

  public enum Action {
    case selected(VaultCollection)
    case share(VaultCollection)
    case changeSharingAccess(VaultCollection)
  }

  @StateObject
  private var viewModel: CollectionsListViewModel

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

  @Environment(\.toast)
  var toast

  @CapabilityState(.collectionSharing)
  var collectionSharingCapabilityState

  public init(
    viewModel: @autoclosure @escaping () -> CollectionsListViewModel,
    action: @escaping (Action) -> Void = { _ in }
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  public var body: some View {
    content
      .frame(maxHeight: .infinity, alignment: .top)
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .navigationBarTitle(CoreL10n.KWVaultItem.Collections.toolsTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toasterOn()
      .toolbar {
        if shouldShowAddToolbarButton {
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
                  .foregroundStyle(Color.ds.text.brand.standard)
              }
            )
          }
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
    switch viewModel.viewState {
    case .loading:
      EmptyView()
    case .emptyCredentialsList:
      emptyCredentialsListIntroView
    case .emptyCollectionsList:
      emptyCollectionsListIntroView
    case .loaded:
      collectionsList
    }
  }

  private var emptyCredentialsListIntroView: some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.collection.outlined),
      title: CoreL10n.CollectionsIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.folder.outlined),
          title: CoreL10n.CollectionsIntro.Subtitle1.v1,
          description: CoreL10n.CollectionsIntro.Description1.v1
        )

        if collectionSharingCapabilityState == .available() {
          FeatureRow(
            asset: ExpressiveIcon(.ds.action.share.outlined),
            title: CoreL10n.CollectionsIntro.subtitle2,
            description: CoreL10n.CollectionsIntro.description2
          )
        }
      }

      Button {
        viewModel.addPassword()
      } label: {
        Label(
          CoreL10n.CollectionsIntro.Cta.v1,
          icon: .ds.arrowRight.outlined
        )
      }
      .buttonStyle(.designSystem(.iconTrailing(.sizeToFit)))
    }
  }

  private var emptyCollectionsListIntroView: some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.collection.outlined),
      title: CoreL10n.CollectionsIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.folder.outlined),
          title: CoreL10n.CollectionsIntro.Subtitle1.v2,
          description: CoreL10n.CollectionsIntro.Description1.v2
        )

        if collectionSharingCapabilityState == .available() {
          FeatureRow(
            asset: ExpressiveIcon(.ds.action.share.outlined),
            title: CoreL10n.CollectionsIntro.subtitle2,
            description: CoreL10n.CollectionsIntro.description2
          )
        }
      }

      Button(CoreL10n.CollectionsIntro.Cta.v2) {
        if viewModel.vaultState == .frozen {
          viewModel.redirectToFrozenPaywall()
        } else {
          showAddition = true
        }
      }
      .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
    }
  }

  private var collectionsList: some View {
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
      CoreL10n.KWVaultItem.Collections.DeleteAlert.title,
      isPresented: $showDelete,
      presenting: collectionToDelete,
      actions: { collectionToDelete in
        Button(CoreL10n.kwDelete, role: .destructive) {
          viewModel.delete(collectionToDelete, with: toast)
        }
        Button(CoreL10n.cancel, role: .cancel) {}
      },
      message: { _ in
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
    .alert(isPresented: $showStarterLimitationAlert) {
      Alert(
        title: Text(CoreL10n.starterLimitationUserSharingUnavailableTitle),
        message: Text(CoreL10n.starterLimitationUserSharingUnavailableDescription),
        dismissButton: .default(Text(CoreL10n.starterLimitationUserSharingUnavailableButton))
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
    .scrollContentBackground(.hidden)
  }

  @ViewBuilder
  private func deleteSwipeAction(for collection: VaultCollection) -> some View {
    if viewModel.isDeleteableOrEditable(collection) {
      Button {
        collectionToDelete = collection
        showDelete = true
      } label: {
        Label(CoreL10n.kwDelete, systemImage: "trash.fill")
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
        Label(CoreL10n.kwEdit, systemImage: "square.and.pencil")
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
            Text(CoreL10n.kwSharedAccess)
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
      Label(CoreL10n.kwShare, systemImage: "arrowshape.turn.up.forward.fill")
        .labelStyle(.titleAndIcon)
    }
    .tint(.ds.container.expressive.neutral.catchy.active)
    .disabled(!viewModel.shouldDisplayShareOption(for: collection))
  }

  private var shouldShowAddToolbarButton: Bool {
    switch viewModel.viewState {
    case .emptyCollectionsList, .loaded:
      return true
    case .loading, .emptyCredentialsList:
      return false
    }
  }
}

struct CollectionsListView_Previews: PreviewProvider {
  static var previews: some View {
    CollectionsListView(viewModel: .mock)
  }
}
