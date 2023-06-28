import Combine
import CorePersonalData
import CorePremium
import Foundation

public class CollectionRowViewModel: ObservableObject, VaultKitServicesInjecting {

    @Published
    var collection: VaultCollection

    var shouldShowSpace: Bool {
        teamSpacesService.availableSpaces.count > 1
    }

    var space: UserSpace? {
        teamSpacesService.displayedUserSpace(for: collection) ?? teamSpacesService.selectedSpace
    }

        private let teamSpacesService: TeamSpacesServiceProtocol
    private let vaultItemsService: VaultItemsServiceProtocol

    public init(
        collection: VaultCollection,
        teamSpacesService: TeamSpacesServiceProtocol,
        vaultItemsService: VaultItemsServiceProtocol
    ) {
        self.collection = collection
        self.teamSpacesService = teamSpacesService
        self.vaultItemsService = vaultItemsService
    }
}

extension CollectionRowViewModel {
    static func mock(collection: VaultCollection) -> CollectionRowViewModel {
        .init(
            collection: collection,
            teamSpacesService: MockVaultKitServicesContainer().teamSpacesService,
            vaultItemsService: MockVaultKitServicesContainer().vaultItemsService
        )
    }
}
