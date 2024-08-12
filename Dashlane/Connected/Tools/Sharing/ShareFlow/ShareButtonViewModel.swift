import CorePremium
import DashTypes
import Foundation
import VaultKit

@MainActor
struct ShareButtonViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {
  let deactivationReason: SharingDeactivationReason?
  let shareFlowViewModelFactory: ShareFlowViewModel.Factory

  let items: [VaultItem]
  let userGroupIds: Set<Identifier>
  let userEmails: Set<String>

  init(
    items: [VaultItem] = [],
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    userSpacesService: UserSpacesService,
    shareFlowViewModelFactory: ShareFlowViewModel.Factory
  ) {
    self.items = items
    self.userGroupIds = userGroupIds
    self.userEmails = userEmails
    self.shareFlowViewModelFactory = shareFlowViewModelFactory

    self.deactivationReason =
      userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
      ? .b2bSharingDisabled : nil
  }

  func makeShareFlowViewModel() -> ShareFlowViewModel {
    return shareFlowViewModelFactory.make(
      items: items, userGroupIds: userGroupIds, userEmails: userEmails)
  }
}

extension ShareButtonViewModel {
  static func mock(
    items: [VaultItem] = [],
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    sharingService: SharingServiceProtocol = SharingServiceMock()
  ) -> ShareButtonViewModel {
    ShareButtonViewModel(
      items: items,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      userSpacesService: .mock(),
      shareFlowViewModelFactory: .init { items, userGroupIds, userEmails in
        .mock(
          items: items, userGroupIds: userGroupIds, userEmails: userEmails,
          sharingService: sharingService)
      })
  }
}
