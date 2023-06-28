import Combine
import CoreLocalization
import CorePersonalData
import CoreUserTracking
import CorePremium
import DashTypes
import DesignSystem
import Foundation
import VaultKit

final class CollectionDetailViewModel: ObservableObject, SessionServicesInjecting {

        @Published
    var collection: VaultCollection {
        didSet {
            updateItems()
        }
    }

    @Published
    var items: [VaultItem]

    var collectionSpace: UserSpace? {
        teamSpacesService.userSpace(for: collection)
    }

    var shouldShowSpace: Bool {
        teamSpacesService.availableSpaces.count > 1
    }

        private let collectionQuickActionsMenuViewModelFactory: CollectionQuickActionsMenuViewModel.Factory
    private let vaultItemRowModelFactory: VaultItemRowModel.Factory

        private let logger: Logger
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol
    private let teamSpacesService: TeamSpacesService

        private var cancellables: Set<AnyCancellable> = []

    init(
        collection: VaultCollection,
        logger: Logger,
        activityReporter: ActivityReporterProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        teamSpacesService: TeamSpacesService,
        collectionQuickActionsMenuViewModelFactory: CollectionQuickActionsMenuViewModel.Factory,
        vaultItemRowModelFactory: VaultItemRowModel.Factory
    ) {
        self.collection = collection
        self.items = vaultItemsService.allItems().filter { collection.contains($0) }
        self.logger = logger
        self.activityReporter = activityReporter
        self.vaultItemsService = vaultItemsService
        self.collectionQuickActionsMenuViewModelFactory = collectionQuickActionsMenuViewModelFactory
        self.vaultItemRowModelFactory = vaultItemRowModelFactory
        self.teamSpacesService = teamSpacesService

        registerPublishers()
    }

    private func registerPublishers() {
        vaultItemsService
            .collectionsPublisher()
            .receive(on: DispatchQueue.main)
                        .sink { [weak self] collections in
                if let collection = collections.first(where: { $0.id == self?.collection.id }) {
                    self?.collection = collection
                }
            }
            .store(in: &cancellables)

        vaultItemsService
            .allItemsPublisher()
            .map { [weak self] items -> [VaultItem] in
                items.filter { self?.collection.contains($0) == true }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }

    private func updateItems() {
        items = vaultItemsService.allItems().filter { collection.contains($0) }
    }
}

extension CollectionDetailViewModel {
    func makeQuickActionsMenuViewModel() -> CollectionQuickActionsMenuViewModel {
        collectionQuickActionsMenuViewModelFactory.make(collection: collection)
    }

    func makeRowViewModel(_ item: VaultItem) -> VaultItemRowModel {
        vaultItemRowModelFactory.make(
            configuration: .init(item: item, isSuggested: false),
            additionalConfiguration: .init(origin: .vault)
        )
    }
}

private extension VaultItemsServiceProtocol {
    func allItems() -> [VaultItem] {
        var allItems: [VaultItem] = []
        allItems.append(contentsOf: credentials)
        allItems.append(contentsOf: secureNotes)
        allItems.append(contentsOf: creditCards)
        allItems.append(contentsOf: bankAccounts)
        allItems.append(contentsOf: identities)
        allItems.append(contentsOf: emails)
        allItems.append(contentsOf: phones)
        allItems.append(contentsOf: addresses)
        allItems.append(contentsOf: companies)
        allItems.append(contentsOf: websites)
        allItems.append(contentsOf: creditCards)
        allItems.append(contentsOf: passports)
        allItems.append(contentsOf: drivingLicenses)
        allItems.append(contentsOf: socialSecurityInformation)
        allItems.append(contentsOf: idCards)
        allItems.append(contentsOf: fiscalInformation)

        return allItems
    }
}

extension CollectionDetailViewModel {
    func remove(_ item: VaultItem, with toast: ToastAction) {
        collection.remove(item)
        do {
            collection = try vaultItemsService.save(collection)
            toast(
                CoreLocalization.L10n.Core.KWVaultItem.Collections.Toast.itemRemoved(1),
                image: .ds.feedback.success.outlined
            )
            activityReporter.report(
                UserEvent.UpdateCollection(
                    action: .deleteCredential,
                    collectionId: self.collection.id.rawValue,
                    isShared: self.collection.isShared,
                    itemCount: 1
                )
            )
        } catch {
            logger[.personalData].error("Error on save", error: error)
        }
    }
}

extension CollectionDetailViewModel {
    static func mock(for collection: VaultCollection) -> CollectionDetailViewModel {
        .init(
            collection: collection,
            logger: FakeLogger(),
            activityReporter: FakeActivityReporter(),
            vaultItemsService: MockVaultConnectedContainer().vaultItemsService,
            teamSpacesService: .mock(),
            collectionQuickActionsMenuViewModelFactory: .init { collection in .mock(collection: collection) },
            vaultItemRowModelFactory: .init { config, additionalConfig in .mock(configuration: config, additionalConfiguration: additionalConfig) }
        )
    }
}
