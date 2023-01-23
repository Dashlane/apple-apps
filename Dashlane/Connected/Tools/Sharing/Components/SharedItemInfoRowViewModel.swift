import Foundation
import CoreSharing
import VaultKit
import SwiftUI
import DashlaneAppKit
import CorePremium

struct SharedItemInfoRowViewModel<Recipient: SharingGroupMember> {
    let item: SharedVaultItemInfo<Recipient>
    let inProgress: Bool

    var userSpace: UserSpace? {
        teamSpacesService.displayedUserSpace(for: item.vaultItem)
    }

    let vaultIconViewModelFactory: VaultItemIconViewModel.Factory
    private let teamSpacesService: TeamSpacesService

    public init(item: SharedVaultItemInfo<Recipient>,
                inProgress: Bool,
                vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
                teamSpacesService: TeamSpacesService) {
        self.item = item
        self.inProgress = inProgress
        self.vaultIconViewModelFactory = vaultIconViewModelFactory
        self.teamSpacesService = teamSpacesService
    }
}
