import Foundation
import VaultKit
import IconLibrary
import DashTypes

@MainActor
class SharingToolViewModel: ObservableObject, SessionServicesInjecting {
    enum State: Hashable {
                                case loading(serviceIsLoading: Bool)
        case empty
        case ready
    }

    let itemsProvider: SharingToolItemsProvider
    let pendingUserGroupsSectionViewModel: SharingPendingUserGroupsSectionViewModel
    let pendingItemGroupsSectionViewModel: SharingPendingItemGroupsSectionViewModel
    let usersSectionViewModel: SharingUsersSectionViewModel
    let userGroupsSectionViewModel: SharingUserGroupsSectionViewModel
    let userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
    let shareButtonViewModelFactory: ShareButtonViewModel.Factory

    @Published
    var state: State = .loading(serviceIsLoading: false)

    init(itemsProviderFactory: SharingToolItemsProvider.Factory,
         pendingUserGroupsSectionViewModelFactory: SharingPendingUserGroupsSectionViewModel.Factory,
         pendingItemGroupsSectionViewModelFactory: SharingPendingItemGroupsSectionViewModel.Factory,
         userGroupsSectionViewModelFactory: SharingUserGroupsSectionViewModel.Factory,
         usersSectionViewModelFactory: SharingUsersSectionViewModel.Factory,
         userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory,
         shareButtonViewModelFactory: ShareButtonViewModel.Factory,
         sharingService: SharingServiceProtocol) {
        itemsProvider = itemsProviderFactory.make()
        self.pendingUserGroupsSectionViewModel = pendingUserGroupsSectionViewModelFactory.make()
        self.pendingItemGroupsSectionViewModel = pendingItemGroupsSectionViewModelFactory.make()
        self.userGroupsSectionViewModel = userGroupsSectionViewModelFactory.make(itemsProvider: itemsProvider)
        self.usersSectionViewModel = usersSectionViewModelFactory.make(itemsProvider: itemsProvider)
        self.userSpaceSwitcherViewModelFactory = userSpaceSwitcherViewModelFactory
        self.shareButtonViewModelFactory = shareButtonViewModelFactory
        let isEmpty =  pendingUserGroupsSectionViewModel.$pendingUserGroups.combineLatest(pendingItemGroupsSectionViewModel.$pendingItemGroups,
                                                                                          userGroupsSectionViewModel.$userGroups,
                                                                                          usersSectionViewModel.$users) { pendingUserGroups, pendingItemGroups, userGroups, users -> Bool? in
            guard let pendingUserGroups, let pendingItemGroups, let userGroups, let users else {
                return nil
            }

            return pendingUserGroups.isEmpty && pendingItemGroups.isEmpty && userGroups.isEmpty && users.isEmpty
        }

        sharingService.isReadyPublisher().receive(on: DispatchQueue.main).combineLatest(isEmpty) { isReady, isEmpty in
            if !isReady {
                return .loading(serviceIsLoading: true)
            } else if let isEmpty {
                return isEmpty ? .empty : .ready
            } else {
                return .loading(serviceIsLoading: false)
            }
        }.assign(to: &$state)
    }
}

extension SharingToolViewModel {
    static func mock(itemsProvider: SharingToolItemsProvider,
                     teamSpacesService: TeamSpacesService,
                     sharingService: SharingServiceProtocol) -> SharingToolViewModel {
        SharingToolViewModel(
            itemsProviderFactory: .init { itemsProvider },
            pendingUserGroupsSectionViewModelFactory: .init {
                SharingPendingUserGroupsSectionViewModel(teamSpacesService: teamSpacesService, sharingService: sharingService) },
            pendingItemGroupsSectionViewModelFactory: .init {
                SharingPendingItemGroupsSectionViewModel(
                    sharingService: sharingService,
                    teamSpacesService: teamSpacesService,
                    vaultItemRowModelFactory: .init { .mock(configuration: $0, additionialConfiguration: $1)}
                )
            },
            userGroupsSectionViewModelFactory: .init { itemsProvider in
                SharingUserGroupsSectionViewModel(
                    itemsProvider: itemsProvider,
                    detailViewModelFactory: .init { .mock(userGroup: $0, itemsProvider: $2) },
                    sharingService: sharingService
                )
            },
            usersSectionViewModelFactory: .init { itemsProvider in
                SharingUsersSectionViewModel(
                    itemsProvider: itemsProvider,
                    sharingService: sharingService,
                    detailViewModelFactory: .init { .mock(user: $0, itemsProvider: $2) },
                    gravatarIconViewModelFactory: .init { .mock(email: $0) }
                )
            },
            userSpaceSwitcherViewModelFactory: .init { .mock },
            shareButtonViewModelFactory: .init {
                .mock(
                    items: $0,
                    userGroupIds: $1,
                    userEmails: $2,
                    sharingService: sharingService
                )
            },
            sharingService: sharingService
        )
    }
}
