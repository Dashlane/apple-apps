import Combine
import CoreFeature
import CorePremium
import DashTypes
import Foundation
import VaultKit

@MainActor
class ShareButtonViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {
  var deactivationReason: SharingDeactivationReason?
  let shareFlowViewModelFactory: ShareFlowViewModel.Factory
  let deeplinkingService: VaultKit.DeepLinkingServiceProtocol

  let items: [VaultItem]
  let userGroupIds: Set<Identifier>
  let userEmails: Set<String>

  var subscriptions: Set<AnyCancellable> = []

  init(
    items: [VaultItem] = [],
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    userSpacesService: UserSpacesService,
    shareFlowViewModelFactory: ShareFlowViewModel.Factory,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: VaultKit.DeepLinkingServiceProtocol
  ) {
    self.items = items
    self.userGroupIds = userGroupIds
    self.userEmails = userEmails
    self.shareFlowViewModelFactory = shareFlowViewModelFactory
    self.deeplinkingService = deeplinkingService

    self.deactivationReason =
      userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
      ? .b2bSharingDisabled : nil

    vaultStateService
      .vaultStatePublisher()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] state in
        switch state {
        case .frozen:
          self?.deactivationReason = .frozenAccount
        case .default:
          self?.deactivationReason =
            userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
            ? .b2bSharingDisabled : nil
        }
      })
      .store(in: &subscriptions)
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
      },
      vaultStateService: .mock,
      deeplinkingService: DeepLinkingService.fakeService)
  }
}
