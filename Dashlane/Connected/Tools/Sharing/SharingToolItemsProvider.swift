import Foundation
import DashTypes
import CoreSharing
import CoreSession
import CorePersonalData
import Combine
import VaultKit

@MainActor
class SharingToolItemsProvider: SessionServicesInjecting {
    @Published
    var vaultItemByIds: [Identifier: VaultItem] = [:]

        @Published
    var sharedIds: Set<Identifier> = []

    public init(vaultItemsService: VaultItemsService,
                teamSpacesService: TeamSpacesService) {
        var publishers: [AnyPublisher<[VaultItem], Never>] = []

        for type in SharingType.allCases {
            switch type {
            case .password:
                publishers.append(vaultItemsService.$credentials.map { $0 as [VaultItem] }.eraseToAnyPublisher())
            case .note:
                publishers.append(vaultItemsService.$secureNotes.map { $0 as [VaultItem] }.eraseToAnyPublisher())
            }
        }

        publishers.combineLatest()
            .map { items in items.flatMap { $0 } }
            .filter(by: teamSpacesService.$selectedSpace)
            .map { items in
                var itemByIds = [Identifier: VaultItem]()
                for item in items {
                    itemByIds[item.id] = item
                }
                return itemByIds
            }
            .assign(to: &$vaultItemByIds)

        $vaultItemByIds.map { Set($0.keys) }.assign(to: &$sharedIds)
    }

    private init(vaultItemByIds: [Identifier: VaultItem] = [:]) {
        self.vaultItemByIds = vaultItemByIds
        self.sharedIds = Set(vaultItemByIds.keys)
    }
}

extension SharingToolItemsProvider {
    static func mock(vaultItemByIds: [Identifier: VaultItem] = [:]) -> SharingToolItemsProvider {
        SharingToolItemsProvider(vaultItemByIds: vaultItemByIds)
    }
}
