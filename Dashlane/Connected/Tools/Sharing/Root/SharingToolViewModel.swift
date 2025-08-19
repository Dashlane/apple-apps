import Combine
import CorePersonalData
import CorePremium
import Foundation
import VaultKit

@MainActor
class SharingToolViewModel: ObservableObject, SessionServicesInjecting {
  enum State: Hashable {
    case loading(serviceIsLoading: Bool)
    case empty(isVaultEmpty: Bool)
    case ready
  }

  let itemsProvider: SharingToolItemsProvider
  let pendingUserGroupsSectionViewModel: SharingPendingUserGroupsSectionViewModel
  let pendingEntitiesSectionViewModel: SharingPendingEntitiesSectionViewModel
  let usersSectionViewModel: SharingUsersSectionViewModel
  let userGroupsSectionViewModel: SharingUserGroupsSectionViewModel
  let userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
  let shareButtonViewModelFactory: ShareButtonViewModel.Factory
  let deepLinkingService: DeepLinkingServiceProtocol

  @Published
  var state: State = .loading(serviceIsLoading: false)

  var cancellables = Set<AnyCancellable>()

  init(
    itemsProviderFactory: SharingToolItemsProvider.Factory,
    pendingUserGroupsSectionViewModelFactory: SharingPendingUserGroupsSectionViewModel.Factory,
    pendingEntititesViewModelFactory: SharingPendingEntitiesSectionViewModel.Factory,
    userGroupsSectionViewModelFactory: SharingUserGroupsSectionViewModel.Factory,
    usersSectionViewModelFactory: SharingUsersSectionViewModel.Factory,
    userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory,
    shareButtonViewModelFactory: ShareButtonViewModel.Factory,
    sharingService: SharingServiceProtocol,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    itemsProvider = itemsProviderFactory.make()
    self.pendingUserGroupsSectionViewModel = pendingUserGroupsSectionViewModelFactory.make()
    self.pendingEntitiesSectionViewModel = pendingEntititesViewModelFactory.make()
    self.userGroupsSectionViewModel = userGroupsSectionViewModelFactory.make(
      itemsProvider: itemsProvider)
    self.usersSectionViewModel = usersSectionViewModelFactory.make(itemsProvider: itemsProvider)
    self.userSpaceSwitcherViewModelFactory = userSpaceSwitcherViewModelFactory
    self.shareButtonViewModelFactory = shareButtonViewModelFactory
    self.deepLinkingService = deepLinkingService

    let pendingItemsIsEmpty = pendingUserGroupsSectionViewModel.$pendingUserGroups.combineLatest(
      pendingEntitiesSectionViewModel.$pendingItemGroups,
      pendingEntitiesSectionViewModel.$pendingCollections
    ) { pendingUserGroups, pendingItemGroups, pendingCollections -> Bool? in
      guard let pendingUserGroups else {
        return nil
      }
      return pendingUserGroups.isEmpty && pendingItemGroups.isEmpty && pendingCollections.isEmpty
    }.eraseToAnyPublisher()

    let itemsIsEmpty = userGroupsSectionViewModel.$userGroups.combineLatest(
      usersSectionViewModel.$users
    ) { userGroups, users -> Bool? in
      guard let userGroups, let users else {
        return nil
      }
      return userGroups.isEmpty && users.isEmpty
    }.eraseToAnyPublisher()

    let isEmpty = pendingItemsIsEmpty.combineLatest(itemsIsEmpty) {
      pendingItemsIsEmpty, itemsIsEmpty -> Bool? in
      guard let pendingItemsIsEmpty, let itemsIsEmpty else {
        return nil
      }

      return pendingItemsIsEmpty && itemsIsEmpty
    }

    let isVaultEmpty = itemsProvider.$vaultItemByIds.map(\.isEmpty).eraseToAnyPublisher()

    sharingService.isReadyPublisher()
      .receive(on: DispatchQueue.main)
      .combineLatest(isEmpty, isVaultEmpty)
      .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
      .sink { isReady, isEmpty, isVaultEmpty in
        if !isReady {
          self.state = .loading(serviceIsLoading: true)
        } else if let isEmpty {
          self.state = isEmpty ? .empty(isVaultEmpty: isVaultEmpty) : .ready
        } else {
          self.state = .loading(serviceIsLoading: false)
        }
      }
      .store(in: &cancellables)
  }

  func addPassword() {
    deepLinkingService.handleLink(.vault(.create(.credential)))
  }
}

extension SharingToolViewModel {
  static func mock(
    itemsProvider: SharingToolItemsProvider,
    userSpacesService: UserSpacesService,
    sharingService: SharingServiceProtocol
  ) -> SharingToolViewModel {
    SharingToolViewModel(
      itemsProviderFactory: .init { itemsProvider },
      pendingUserGroupsSectionViewModelFactory: .init {
        SharingPendingUserGroupsSectionViewModel(
          userSpacesService: userSpacesService, sharingService: sharingService)
      },
      pendingEntititesViewModelFactory: .init {
        SharingPendingEntitiesSectionViewModel(
          sharingService: sharingService,
          userSpacesService: userSpacesService,
          vaultItemIconViewModelFactory: .init { item in .mock(item: item) }
        )
      },
      userGroupsSectionViewModelFactory: .init { itemsProvider in
        SharingUserGroupsSectionViewModel(
          itemsProvider: itemsProvider,
          detailViewModelFactory: .init { .mock(userGroup: $0, itemsProvider: $2) },
          sharingService: sharingService,
          userSpacesService: userSpacesService
        )
      },
      usersSectionViewModelFactory: .init { itemsProvider in
        SharingUsersSectionViewModel(
          itemsProvider: itemsProvider,
          sharingService: sharingService,
          detailViewModelFactory: .init { .mock(user: $0, item: Credential(), itemsProvider: $2) },
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
      sharingService: sharingService,
      deepLinkingService: DeepLinkingService.fakeService
    )
  }
}
