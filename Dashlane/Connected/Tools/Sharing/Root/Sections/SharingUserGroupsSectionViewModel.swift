import Foundation
import DashTypes
import CoreSharing
import CoreSession
import CorePersonalData
import CorePremium
import Combine
import VaultKit

@MainActor
class SharingUserGroupsSectionViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var userGroups: [SharingItemsUserGroup]?

    private let detailViewModelFactory: SharingItemsUserGroupDetailViewModel.Factory
    private let itemsProvider: SharingToolItemsProvider

    public init(itemsProvider: SharingToolItemsProvider,
                detailViewModelFactory: SharingItemsUserGroupDetailViewModel.Factory,
                sharingService: SharingServiceProtocol,
                teamSpacesService: VaultKit.TeamSpacesServiceProtocol) {
        self.itemsProvider = itemsProvider
        self.detailViewModelFactory = detailViewModelFactory

        let sharingItemUserGroups = sharingService.sharingUserGroupsPublisher()
        sharingItemUserGroups
            .combineLatest(teamSpacesService.selectedSpacePublisher) { sharingItemUserGroups, selectedSpace in
                switch selectedSpace {
                case .both, .business:
                    return sharingItemUserGroups
                case .personal:
                    return []
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$userGroups)
    }

    func makeDetailViewModel(userGroup: SharingItemsUserGroup) -> SharingItemsUserGroupDetailViewModel {
                let userGroupUpdatePublisher = $userGroups.map {
            $0?.first {
                $0.id == userGroup.id
            } ?? userGroup
        }.eraseToAnyPublisher()

        return detailViewModelFactory.make(userGroup: userGroup, userGroupUpdatePublisher: userGroupUpdatePublisher, itemsProvider: itemsProvider)
    }
}
