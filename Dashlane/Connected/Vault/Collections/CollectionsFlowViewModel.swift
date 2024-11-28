import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import Foundation
import PremiumKit
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

  @Published
  var vaultState: VaultState = .default

  let detailViewModelFactory: VaultDetailViewModel.Factory
  let collectionsListViewModelFactory: CollectionsListViewModel.Factory
  let collectionDetailViewModelFactory: CollectionDetailViewModel.Factory
  let collectionShareFlowViewModelFactory: CollectionShareFlowViewModel.Factory
  let sharingCollectionMembersViewModelFactory: SharingCollectionMembersDetailViewModel.Factory

  private let vaultCollectionsStore: VaultCollectionsStore
  private let database: ApplicationDatabase
  private let vaultStateService: VaultStateServiceProtocol
  private let deeplinkingService: DeepLinkingServiceProtocol

  private var cancellables: Set<AnyCancellable> = []

  init(
    initialStep: CollectionsFlowViewModel.Step = .list,
    vaultCollectionsStore: VaultCollectionsStore,
    database: ApplicationDatabase,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
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
    self.vaultStateService = vaultStateService
    self.deeplinkingService = deeplinkingService
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

    vaultStateService
      .vaultStatePublisher()
      .assign(to: &$vaultState)
  }

  func handleCollectionsListAction(_ action: CollectionsListView.Action) {
    switch action {
    case .selected(let collection):
      steps.append(.collectionDetail(collection))
    case .share(let collection):
      guard vaultState != .frozen else {
        deeplinkingService.handleLink(
          .premium(.planPurchase(initialView: .paywall(trigger: .frozenAccount))))
        return
      }
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
      vaultStateService: .mock,
      deeplinkingService: DeepLinkingService.fakeService,
      detailViewModelFactory: .init { .mock() },
      collectionsListViewModelFactory: .init { .mock },
      collectionDetailViewModelFactory: .init { collection in .mock(for: collection) },
      collectionShareFlowViewModelFactory: .init { _, _, _ in .mock() },
      sharingCollectionMembersViewModelFactory: .init { .mock(collection: $0) }
    )
  }
}
