import Foundation
import DashTypes
import CoreSharing
import CoreSession
import CorePersonalData
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
                sharingService: SharingServiceProtocol) {
        self.itemsProvider = itemsProvider
        self.detailViewModelFactory = detailViewModelFactory

        sharingService.sharingUserGroupsPublisher()
            .map { $0 }
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
