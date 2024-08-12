import Combine
import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import VaultKit

@MainActor
public class CollectionsFlowViewModel: ObservableObject, SessionServicesInjecting {

  enum Step {
    case list
    case collectionDetail(VaultCollection)
    case itemDetail(VaultItem)
  }

  @Published
  var steps: [Step]

  @Published
  var collectionToShare: VaultCollection?

  @Published
  var showCannotShareWithAttachments: Bool = false

  @Published
  var collectionAccessToChange: VaultCollection?

  let detailViewModelFactory: VaultDetailViewModel.Factory
  let collectionsListViewModelFactory: CollectionsListViewModel.Factory
  let collectionDetailViewModelFactory: CollectionDetailViewModel.Factory
  let collectionShareFlowViewModelFactory: CollectionShareFlowViewModel.Factory
  let sharingCollectionMembersViewModelFactory: SharingCollectionMembersDetailViewModel.Factory

  private let vaultCollectionsStore: VaultCollectionsStore
  private let database: ApplicationDatabase

  private var cancellables: Set<AnyCancellable> = []

  init(
    initialStep: CollectionsFlowViewModel.Step = .list,
    vaultCollectionsStore: VaultCollectionsStore,
    database: ApplicationDatabase,
    detailViewModelFactory: VaultDetailViewModel.Factory,
    collectionsListViewModelFactory: CollectionsListViewModel.Factory,
    collectionDetailViewModelFactory: CollectionDetailViewModel.Factory,
    collectionShareFlowViewModelFactory: CollectionShareFlowViewModel.Factory,
    sharingCollectionMembersViewModelFactory: SharingCollectionMembersDetailViewModel.Factory
  ) {
    self.vaultCollectionsStore = vaultCollectionsStore
    self.detailViewModelFactory = detailViewModelFactory
    self.collectionsListViewModelFactory = collectionsListViewModelFactory
    self.collectionDetailViewModelFactory = collectionDetailViewModelFactory
    self.collectionShareFlowViewModelFactory = collectionShareFlowViewModelFactory
    self.sharingCollectionMembersViewModelFactory = sharingCollectionMembersViewModelFactory
    self.steps = [initialStep]
    self.database = database
    self.registerPublishers()
  }

  private func registerPublishers() {
    vaultCollectionsStore
      .$collections
      .receive(on: DispatchQueue.main)
      .sink { [weak self] collections in
        self?.handleUpdate(on: collections)
      }
      .store(in: &cancellables)
  }

  func handleCollectionsListAction(_ action: CollectionsListView.Action) {
    switch action {
    case .selected(let collection):
      steps.append(.collectionDetail(collection))
    case .share(let collection):
      do {
        try database.checkShareability(of: Array(collection.itemIds))
        collectionToShare = collection
      } catch {
        showCannotShareWithAttachments = true
      }

    case .changeSharingAccess(let collection):
      collectionAccessToChange = collection
    }
  }

  func handleCollectionDetailAction(_ action: CollectionDetailView.Action) {
    switch action {
    case .selected(let item):
      steps.append(.itemDetail(item))
    case .share(let collection):
      collectionToShare = collection
    case .changeSharingAccess(let collection):
      collectionAccessToChange = collection
    }
  }

  func handleSharingCollectionMembersDetailAction(
    _ action: SharingCollectionMembersDetailView.Action, with toast: ToastAction
  ) {
    switch action {
    case .done(let accessChanged):
      collectionAccessToChange = nil
      if accessChanged {
        toast(
          CoreLocalization.L10n.Core.kwSharedAccessUpdatedToast,
          image: .ds.feedback.success.outlined)
      }
    }
  }

  func makeCollectionShareFlowViewModel(for collection: VaultCollection)
    -> CollectionShareFlowViewModel
  {
    collectionShareFlowViewModelFactory.make(collection: collection)
  }

  func makeSharingCollectionMembersViewModel(for collection: VaultCollection)
    -> SharingCollectionMembersDetailViewModel
  {
    sharingCollectionMembersViewModelFactory.make(collection: collection)
  }

  private func makeCollectionDetailViewModel(for collection: VaultCollection)
    -> CollectionDetailViewModel
  {
    collectionDetailViewModelFactory.make(collection: collection)
  }

  func makeDetailViewModel() -> VaultDetailViewModel {
    detailViewModelFactory.make()
  }

  private func handleUpdate(on collections: [VaultCollection]) {
    guard case .collectionDetail(let collection) = steps.last,
      !collections.contains(where: { $0.id == collection.id })
    else { return }
    steps.removeLast()
  }
}

extension CollectionsFlowViewModel {
  public static var mock: CollectionsFlowViewModel {
    .init(
      vaultCollectionsStore: MockVaultConnectedContainer().vaultCollectionsStore,
      database: MockVaultConnectedContainer().database,
      detailViewModelFactory: .init { .mock() },
      collectionsListViewModelFactory: .init { .mock },
      collectionDetailViewModelFactory: .init { collection in .mock(for: collection) },
      collectionShareFlowViewModelFactory: .init { _, _, _ in .mock() },
      sharingCollectionMembersViewModelFactory: .init { .mock(collection: $0) }
    )
  }
}
