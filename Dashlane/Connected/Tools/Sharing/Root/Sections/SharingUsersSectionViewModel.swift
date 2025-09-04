import Combine
import CorePersonalData
import CoreSession
import CoreSharing
import CoreTypes
import Foundation
import VaultKit

@MainActor
class SharingUsersSectionViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var users: [SharingEntitiesUser]?

  let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory
  private let detailViewModelFactory: SharingItemsUserDetailViewModel.Factory
  private let itemsProvider: SharingToolItemsProvider

  public init(
    itemsProvider: SharingToolItemsProvider,
    sharingService: SharingServiceProtocol,
    detailViewModelFactory: SharingItemsUserDetailViewModel.Factory,
    gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory
  ) {
    self.itemsProvider = itemsProvider
    self.detailViewModelFactory = detailViewModelFactory
    self.gravatarIconViewModelFactory = gravatarIconViewModelFactory

    let sharingItemUsers = sharingService.sharingUsersPublisher()
    sharingItemUsers.combineLatest(itemsProvider.$sharedIds) { sharingItemUsers, sharedIds in
      sharingItemUsers.filter { sharingItemUser in
        return sharingItemUser.items.contains { item in
          sharedIds.contains(item.id)
        }
      }
    }
    .receive(on: DispatchQueue.main)
    .assign(to: &$users)
  }

  func makeDetailViewModel(user: SharingEntitiesUser) -> SharingItemsUserDetailViewModel {
    let userUpdatePublisher = $users.map {
      $0?.first {
        $0.id == user.id
      } ?? user
    }.eraseToAnyPublisher()

    return detailViewModelFactory.make(
      user: user, userUpdatePublisher: userUpdatePublisher, itemsProvider: itemsProvider)
  }
}
