import CoreLocalization
import CorePersonalData
import CoreUserTracking
import CorePremium
import DashTypes
import DesignSystem
import Foundation

public class CollectionsListViewModel: ObservableObject, VaultKitServicesInjecting {

    @Published
    var collections: [VaultCollection] = []

        private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory
    let collectionRowViewModelFactory: CollectionRowViewModel.Factory

        private let logger: Logger
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol
    private let teamSpacesService: TeamSpacesServiceProtocol

    public init(
        logger: Logger,
        activityReporter: ActivityReporterProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        teamSpacesService: TeamSpacesServiceProtocol,
        collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
        collectionRowViewModelFactory: CollectionRowViewModel.Factory
    ) {
        self.logger = logger
        self.activityReporter = activityReporter
        self.vaultItemsService = vaultItemsService
        self.teamSpacesService = teamSpacesService
        self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
        self.collectionRowViewModelFactory = collectionRowViewModelFactory

        registerPublishers()
    }

    private func registerPublishers() {
        vaultItemsService
            .collectionsPublisher()
            .filter(by: teamSpacesService.selectedSpacePublisher)
            .receive(on: DispatchQueue.main)
            .assign(to: &$collections)
    }

    func delete(_ collection: VaultCollection, with toast: ToastAction) {
        do {
            try vaultItemsService.delete(collection)
            reportDeletion(of: collection)
            toast(L10n.Core.KWVaultItem.Collections.deleted(collection.name), image: .ds.feedback.success.outlined)
        } catch {
            logger[.personalData].error("Error on save", error: error)
        }
    }
}

extension CollectionsListViewModel {
    func makeCollectionNamingViewModel() -> CollectionNamingViewModel {
        collectionNamingViewModelFactory.make(mode: .addition)
    }

    func makeCollectionNamingViewModel(for collection: VaultCollection) -> CollectionNamingViewModel {
        collectionNamingViewModelFactory.make(mode: .edition(collection))
    }
}

private extension CollectionsListViewModel {
    func reportDeletion(of collection: VaultCollection) {
        activityReporter.report(
            UserEvent.UpdateCollection(
                action: .delete,
                collectionId: collection.id.rawValue,
                isShared: collection.isShared,
                itemCount: collection.items.count
            )
        )
    }
}

extension CollectionsListViewModel {
    func reportCollectionSelection(_ collection: VaultCollection) {
        activityReporter.report(
            UserEvent.SelectCollection(
                collectionId: collection.id.rawValue,
                collectionSelectOrigin: .collectionList
            )
        )
    }
}

extension CollectionsListViewModel {
    var shouldShowSpace: Bool {
        teamSpacesService.availableSpaces.count > 1
    }
    
    func userSpace(for collection: VaultCollection) -> UserSpace? {
        teamSpacesService.userSpace(for: collection)
    }
}

extension CollectionsListViewModel {
    private convenience init(
        collections: [VaultCollection],
        logger: Logger,
        activityReporter: ActivityReporterProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        teamSpacesService: TeamSpacesServiceProtocol,
        collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
        collectionRowViewModelFactory: CollectionRowViewModel.Factory
    ) {
        self.init(
            logger: logger,
            activityReporter: activityReporter,
            vaultItemsService: vaultItemsService,
            teamSpacesService: teamSpacesService,
            collectionNamingViewModelFactory: collectionNamingViewModelFactory,
            collectionRowViewModelFactory: collectionRowViewModelFactory
        )
        self.collections = collections
    }

    public static var mock: CollectionsListViewModel {
        .init(
            collections: PersonalDataMock.Collections.all,
            logger: LoggerMock(),
            activityReporter: FakeActivityReporter(),
            vaultItemsService: MockVaultKitServicesContainer().vaultItemsService,
            teamSpacesService: MockVaultKitServicesContainer().teamSpacesService,
            collectionNamingViewModelFactory: .init { mode in .mock(mode: mode) },
            collectionRowViewModelFactory: .init { collection in .mock(collection: collection) }
        )
    }
}
