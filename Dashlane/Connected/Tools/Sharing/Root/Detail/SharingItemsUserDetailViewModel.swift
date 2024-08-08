import Combine
import CorePersonalData
import CorePremium
import CoreSharing
import DashTypes
import SwiftUI
import VaultKit

@MainActor
class SharingItemsUserDetailViewModel: ObservableObject, SessionServicesInjecting {

  @Published
  var user: SharingEntitiesUser

  @Published
  var items: [SharedVaultItemInfo<User<ItemGroup>>] = []

  @Published
  private var actionInProgressIds: Set<Identifier> = []

  @Published
  var alertMessage: String?

  let detailViewModelFactory: VaultDetailViewModel.Factory
  private let sharingService: SharingServiceProtocol
  private let userSpacesService: UserSpacesService
  private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory
  private let accessControl: AccessControlProtocol
  let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory

  init(
    user: SharingEntitiesUser,
    userUpdatePublisher: AnyPublisher<SharingEntitiesUser, Never>,
    itemsProvider: SharingToolItemsProvider,
    vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
    gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory,
    detailViewModelFactory: VaultDetailViewModel.Factory,
    userSpacesService: UserSpacesService,
    sharingService: SharingServiceProtocol,
    accessControl: AccessControlProtocol
  ) {
    self.vaultIconViewModelFactory = vaultIconViewModelFactory
    self.detailViewModelFactory = detailViewModelFactory
    self.gravatarIconViewModelFactory = gravatarIconViewModelFactory
    self.userSpacesService = userSpacesService
    self.sharingService = sharingService
    self.accessControl = accessControl
    self.user = user

    userUpdatePublisher.assign(to: &$user)

    $user.combineLatest(itemsProvider.$vaultItemByIds) { user, vaultItemByIds in
      user.items.compactMap { item in
        guard let vaultItem = vaultItemByIds[item.id] else {
          return nil
        }

        return SharedVaultItemInfo(
          vaultItem: vaultItem, group: item.info, recipient: item.recipient)
      }
    }.assign(to: &$items)
  }

  func changePermission(
    for item: SharedVaultItemInfo<User<ItemGroup>>, to permission: SharingPermission
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

  func revoke(_ item: SharedVaultItemInfo<User<ItemGroup>>) {
    trackActionProgress(on: item) {
      do {
        try await self.sharingService.revoke(
          in: item.group, users: [item.recipient], userGroupMembers: nil, loggedItem: item.vaultItem
        )
      } catch {
        self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
      }
    }
  }

  func resendInvite(for item: SharedVaultItemInfo<User<ItemGroup>>) {
    trackActionProgress(on: item) {
      do {
        try await self.sharingService.resendInvites(to: [item.recipient], in: item.group)
        self.alertMessage = L10n.Localizable.kwResendGroupInviteSuccess
      } catch {
        self.alertMessage = L10n.Localizable.kwResendGroupInviteFailure
      }
    }
  }

  private func trackActionProgress(
    on item: SharedVaultItemInfo<User<ItemGroup>>, _ action: @escaping () async -> Void
  ) {
    Task {
      actionInProgressIds.insert(item.id)
      await action()
      actionInProgressIds.remove(item.id)
    }
  }

  func makeRowViewModel(item: SharedVaultItemInfo<User<ItemGroup>>) -> SharedItemInfoRowViewModel<
    User<ItemGroup>
  > {
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

extension SharingItemsUserDetailViewModel {
  static func mock(
    user: SharingEntitiesUser,
    item: VaultItem,
    itemsProvider: SharingToolItemsProvider,
    vaultIconViewModelFactory: VaultItemIconViewModel.Factory = .init { .mock(item: $0) },
    gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory = .init { .mock(email: $0) },
    userSpacesService: UserSpacesService = UserSpacesService.mock(),
    sharingService: SharingServiceProtocol = SharingServiceMock(),
    accessControl: AccessControlProtocol = FakeAccessControl(accept: true)
  ) -> SharingItemsUserDetailViewModel {
    SharingItemsUserDetailViewModel(
      user: user,
      userUpdatePublisher: Empty(completeImmediately: false).eraseToAnyPublisher(),
      itemsProvider: itemsProvider,
      vaultIconViewModelFactory: vaultIconViewModelFactory,
      gravatarIconViewModelFactory: gravatarIconViewModelFactory,
      detailViewModelFactory: .init { .mock() },
      userSpacesService: userSpacesService,
      sharingService: sharingService,
      accessControl: accessControl
    )
  }
}
