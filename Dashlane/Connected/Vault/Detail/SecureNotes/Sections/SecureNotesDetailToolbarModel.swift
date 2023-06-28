import CorePersonalData
import CorePremium
import CoreSharing
import Foundation
import SwiftUI
import VaultKit

class SecureNotesDetailToolbarModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var shouldShowLockButton: Bool {
        !teamSpacesService.isSSOUser
    }

    var selectedUserSpace: UserSpace {
        teamSpacesService.userSpace(for: item) ?? .personal
    }

    var availableUserSpaces: [UserSpace] {
        teamSpacesService.availableSpaces.filter { $0 != .both }
    }

    let shareButtonViewModelFactory: ShareButtonViewModel.Factory

    let service: DetailService<SecureNote>

    private var teamSpacesService: VaultKit.TeamSpacesServiceProtocol {
        service.teamSpacesService
    }

    init(service: DetailService<SecureNote>,
         shareButtonViewModelFactory: ShareButtonViewModel.Factory) {
        self.service = service
        self.shareButtonViewModelFactory = shareButtonViewModelFactory
    }
}

extension SecureNotesDetailToolbarModel {
    static func mock(service: DetailService<SecureNote>) -> SecureNotesDetailToolbarModel {
        SecureNotesDetailToolbarModel(
            service: service,
            shareButtonViewModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) }
        )
    }
}
