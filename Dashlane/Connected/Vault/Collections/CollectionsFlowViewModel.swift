import Combine
import CorePersonalData
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

        let detailViewFactory: DetailView.Factory
    let collectionsListViewModelFactory: CollectionsListViewModel.Factory
    let collectionDetailViewModelFactory: CollectionDetailViewModel.Factory

        private let vaultItemsService: VaultItemsServiceProtocol

        private var cancellables: Set<AnyCancellable> = []

    init(
        initialStep: CollectionsFlowViewModel.Step = .list,
        vaultItemsService: VaultItemsServiceProtocol,
        detailViewFactory: DetailView.Factory,
        collectionsListViewModelFactory: CollectionsListViewModel.Factory,
        collectionDetailViewModelFactory: CollectionDetailViewModel.Factory
    ) {
        self.vaultItemsService = vaultItemsService
        self.detailViewFactory = detailViewFactory
        self.collectionsListViewModelFactory = collectionsListViewModelFactory
        self.collectionDetailViewModelFactory = collectionDetailViewModelFactory
        self.steps = [initialStep]

        self.registerPublishers()
    }

    private func registerPublishers() {
        vaultItemsService.collectionsPublisher()
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
        }
    }

    func handleCollectionDetailAction(_ action: CollectionDetailView.Action) {
        switch action {
        case .selected(let item):
            steps.append(.itemDetail(item))
        }
    }

    private func makeCollectionDetailViewModel(for collection: VaultCollection) -> CollectionDetailViewModel {
        collectionDetailViewModelFactory.make(collection: collection)
    }

    private func handleUpdate(on collections: [VaultCollection]) {
                        guard case .collectionDetail(let collection) = steps.last,
              !collections.contains(where: { $0.id == collection.id })
        else { return }
        steps.removeLast()
    }
}

public extension CollectionsFlowViewModel {
    static var mock: CollectionsFlowViewModel {
        .init(
            vaultItemsService: MockVaultConnectedContainer().vaultItemsService,
            detailViewFactory: .init { _, _ in .mock(item: PersonalDataMock.Credentials.amazon) },
            collectionsListViewModelFactory: .init { .mock },
            collectionDetailViewModelFactory: .init { collection in .mock(for: collection) }
        )
    }
}
