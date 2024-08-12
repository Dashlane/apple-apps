import Combine
import CorePersonalData
import CorePremium
import CoreSharing
import DashTypes
import SwiftUI
import VaultKit

@MainActor
class SharingItemsUserGroupDetailViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var userGroup: SharingEntitiesUserGroup

  @Published
  var items: [SharedVaultItemInfo<UserGroupMember<ItemGroup>>] = []

  @Published
  private var actionInProgressIds: Set<Identifier> = []

  @Published
  var alertMessage: String?

  private let sharingService: SharingServiceProtocol
  private let userSpacesService: UserSpacesService
  private let accessControl: AccessControlProtocol
  private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory
  let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory
  let detailViewModelFactory: VaultDetailViewModel.Factory

  init(
    userGroup: SharingEntitiesUserGroup,
    userGroupUpdatePublisher: AnyPublisher<SharingEntitiesUserGroup, Never>,
    itemsProvider: SharingToolItemsProvider,
    vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
    gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory,
    userSpacesService: UserSpacesService,
    detailViewModelFactory: VaultDetailViewModel.Factory,
    sharingService: SharingServiceProtocol,
    accessControl: AccessControlProtocol
  ) {
    self.vaultIconViewModelFactory = vaultIconViewModelFactory
    self.gravatarIconViewModelFactory = gravatarIconViewModelFactory
    self.userSpacesService = userSpacesService
    self.sharingService = sharingService
    self.userGroup = userGroup
    self.accessControl = accessControl
    self.detailViewModelFactory = detailViewModelFactory

    userGroupUpdatePublisher.assign(to: &$userGroup)

    $userGroup.combineLatest(itemsProvider.$vaultItemByIds) { userGroup, vaultItemByIds in
      userGroup.items.compactMap { item in
        guard let vaultItem = vaultItemByIds[item.id] else {
          return nil
        }

        return SharedVaultItemInfo(
          vaultItem: vaultItem, group: item.info, recipient: item.recipient)
      }
    }.assign(to: &$items)
  }

  func changePermission(
    for item: SharedVaultItemInfo<UserGroupMember<ItemGroup>>, to permission: SharingPermission
  ) {
    trackActionProgress(on: item) {
      do {
        try await self.sharingService.updatePermission(
          permission, of: item.recipient, in: item.group, loggedItem: item.vaultItem)
      } catch {
        self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
      }
    }
  }

  func revoke(_ item: SharedVaultItemInfo<UserGroupMember<ItemGroup>>) {
    trackActionProgress(on: item) {
      do {
        try await self.sharingService.revoke(
          in: item.group, users: nil, userGroupMembers: [item.recipient], loggedItem: item.vaultItem
        )
      } catch {
        self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
      }
    }
  }

  private func trackActionProgress(
    on item: SharedVaultItemInfo<UserGroupMember<ItemGroup>>, _ action: @escaping () async -> Void
  ) {
    Task {
      actionInProgressIds.insert(item.id)
      await action()
      actionInProgressIds.remove(item.id)
    }
  }

  func makeRowViewModel(item: SharedVaultItemInfo<UserGroupMember<ItemGroup>>)
    -> SharedItemInfoRowViewModel<UserGroupMember<ItemGroup>>
  {
    SharedItemInfoRowViewModel(
      item: item,
      inProgress: actionInProgressIds.contains(item.id),
      vaultIconViewModelFactory: vaultIconViewModelFactory,
      userSpacesService: userSpacesService
    )
  }

  func requestShowDetail(for item: VaultItem, _ access: @escaping () -> Void) {
    if let secureItem = item as? SecureItem, secureItem.secured {
      accessControl.requestAccess().sinkOnce { success in
        if success {
          access()
        }
      }
    } else {
      access()
    }
  }
}

extension SharingItemsUserGroupDetailViewModel {
  static func mock(
    userGroup: SharingEntitiesUserGroup,
    itemsProvider: SharingToolItemsProvider,
    vaultIconViewModelFactory: VaultItemIconViewModel.Factory = .init { .mock(item: $0) },
    gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory = .init { .mock(email: $0) },
    userSpacesService: UserSpacesService = UserSpacesService.mock(),
    sharingService: SharingServiceProtocol = SharingServiceMock(),
    accessControl: AccessControlProtocol = FakeAccessControl(accept: true)
  ) -> SharingItemsUserGroupDetailViewModel {
    SharingItemsUserGroupDetailViewModel(
      userGroup: userGroup,
      userGroupUpdatePublisher: Empty(completeImmediately: false).eraseToAnyPublisher(),
      itemsProvider: itemsProvider,
      vaultIconViewModelFactory: vaultIconViewModelFactory,
      gravatarIconViewModelFactory: gravatarIconViewModelFactory,
      userSpacesService: userSpacesService,
      detailViewModelFactory: .init { .mock() },
      sharingService: sharingService,
      accessControl: accessControl
    )
  }
}
