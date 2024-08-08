import Combine
import CorePersonalData
import CorePremium
import CoreSession
import CoreSharing
import DashTypes
import Foundation
import VaultKit

@MainActor
class SharingPendingUserGroupsSectionViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var pendingUserGroups: [PendingUserGroup]?

  private let sharingService: SharingServiceProtocol

  public init(
    userSpacesService: UserSpacesService,
    sharingService: SharingServiceProtocol
  ) {
    self.sharingService = sharingService
    let userGroups = sharingService.pendingUserGroupsPublisher()
    userGroups.combineLatest(userSpacesService.$configuration) { userGroups, configuration in
      switch configuration.selectedSpace {
      case .personal:
        return []
      case .both, .team:
        return userGroups
      }
    }
    .receive(on: DispatchQueue.main)
    .assign(to: &$pendingUserGroups)
  }

  func accept(_ userGroup: PendingUserGroup) async throws {
    try await sharingService.accept(userGroup.userGroupInfo)
  }

  func refuse(_ userGroup: PendingUserGroup) async throws {
    try await sharingService.refuse(userGroup.userGroupInfo)
  }
}
