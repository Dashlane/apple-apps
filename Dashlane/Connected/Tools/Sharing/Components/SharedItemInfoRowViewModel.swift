import Combine
import CorePersonalData
import CorePremium
import CoreSharing
import Foundation
import IconLibrary
import SwiftUI
import VaultKit

struct SharedItemInfoRowViewModel<Recipient: SharingGroupMember> {
  let item: SharedVaultItemInfo<Recipient>
  let inProgress: Bool

  var userSpace: UserSpace? {
    userSpacesService.configuration.displayedUserSpace(for: item.vaultItem)
  }

  private let userSpacesService: UserSpacesService

  private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory

  public init(
    item: SharedVaultItemInfo<Recipient>,
    inProgress: Bool,
    vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
    userSpacesService: UserSpacesService
  ) {
    self.item = item
    self.inProgress = inProgress
    self.vaultIconViewModelFactory = vaultIconViewModelFactory
    self.userSpacesService = userSpacesService
  }

  func makeIconViewModel() -> VaultItemIconViewModel {
    vaultIconViewModelFactory.make(item: item.vaultItem)
  }
}

extension SharedItemInfoRowViewModel where Recipient == UserGroupMember<UserGroup> {
  @MainActor
  static func mock(isAdmin: Bool, inProgress: Bool) -> Self {
    .init(
      item: .init(
        vaultItem: Credential(
          login: "_",
          secondaryLogin: "_",
          title: "Credential Title",
          password: "_",
          email: "_",
          sharingPermission: isAdmin ? .admin : nil
        ),
        group: .mock(),
        recipient: Recipient.mock()
      ),
      inProgress: inProgress,
      vaultIconViewModelFactory: .init { .mock(item: $0) },
      userSpacesService: .mock()
    )
  }
}
