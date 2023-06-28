import Combine
import CoreLocalization
import CorePersonalData
import CoreUserTracking
import DashTypes
import DesignSystem
import Foundation

public final class CollectionQuickActionsMenuViewModel: ObservableObject, VaultKitServicesInjecting {

    @Published
    var collection: VaultCollection

        private let logger: Logger
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol

        private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory

        private var cancellables: Set<AnyCancellable> = []

    public init(
        collection: VaultCollection,
        logger: Logger,
        activityReporter: ActivityReporterProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        collectionNamingViewModelFactory: CollectionNamingViewModel.Factory
    ) {
        self.collection = collection
        self.logger = logger
        self.activityReporter = activityReporter
        self.vaultItemsService = vaultItemsService
        self.collectionNamingViewModelFactory = collectionNamingViewModelFactory

        self.registerPublishers()
    }

    private func registerPublishers() {
        vaultItemsService
            .collectionsPublisher()
            .compactMap { [weak self] collections in
                return collections.first(where: { $0.id == self?.collection.id })
            }
            .assign(to: &$collection)
    }

    func deleteCollection(with toast: ToastAction) {
        do {
            try vaultItemsService.delete(collection)
            reportDeletion()
            toast(L10n.Core.KWVaultItem.Collections.deleted(collection.name), image: .ds.feedback.success.outlined)
        } catch {
            logger[.personalData].error("Error on save", error: error)
        }
    }

    func makeEditableCollectionNamingViewModel() -> CollectionNamingViewModel {
        collectionNamingViewModelFactory.make(mode: .edition(collection))
    }
}

extension CollectionQuickActionsMenuViewModel {
    func reportAppearance() {
        activityReporter.reportPageShown(.collectionQuickActionsDropdown)
    }

    func reportDeletionAppearance() {
        activityReporter.reportPageShown(.collectionDelete)
    }

    func reportDeletion() {
        activityReporter.report(
            UserEvent.UpdateCollection(
                action: .delete,
                collectionId: self.collection.id.rawValue,
                isShared: self.collection.isShared,
                itemCount: self.collection.items.count
            )
        )
    }
}

public extension CollectionQuickActionsMenuViewModel {
    static func mock(collection: VaultCollection) -> CollectionQuickActionsMenuViewModel {
        .init(
            collection: collection,
            logger: LoggerMock(),
            activityReporter: FakeActivityReporter(),
            vaultItemsService: MockVaultKitServicesContainer().vaultItemsService,
            collectionNamingViewModelFactory: .init { .mock(mode: $0) }
        )
    }
}
