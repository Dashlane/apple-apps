import Combine
import CorePersonalData
import CorePremium
import CoreSession
import CoreSharing
import DashTypes
import Foundation
import VaultKit

@MainActor
class SharingUserGroupsSectionViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var userGroups: [SharingEntitiesUserGroup]?

  private let detailViewModelFactory: SharingItemsUserGroupDetailViewModel.Factory
  private let itemsProvider: SharingToolItemsProvider

  public init(
    itemsProvider: SharingToolItemsProvider,
    detailViewModelFactory: SharingItemsUserGroupDetailViewModel.Factory,
    sharingService: SharingServiceProtocol,
    userSpacesService: UserSpacesService
  ) {
    self.itemsProvider = itemsProvider
    self.detailViewModelFactory = detailViewModelFactory

    let sharingItemUserGroups = sharingService.sharingUserGroupsPublisher()
    sharingItemUserGroups
      .combineLatest(userSpacesService.$configuration) { sharingItemUserGroups, configuration in
        switch configuration.selectedSpace {
        case .both, .team:
          return sharingItemUserGroups
        case .personal:
          return []
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$userGroups)
  }

  func makeDetailViewModel(userGroup: SharingEntitiesUserGroup)
    -> SharingItemsUserGroupDetailViewModel
  {
    let userGroupUpdatePublisher = $userGroups.map {
      $0?.first {
        $0.id == userGroup.id
      } ?? userGroup
    }.eraseToAnyPublisher()

    return detailViewModelFactory.make(
      userGroup: userGroup, userGroupUpdatePublisher: userGroupUpdatePublisher,
      itemsProvider: itemsProvider)
  }
}
