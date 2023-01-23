import Foundation
import DashTypes
import CoreSharing
import CoreSession
import CorePersonalData
import Combine
import VaultKit

@MainActor
class SharingPendingUserGroupsSectionViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var pendingUserGroups: [PendingUserGroup]?

    private let sharingService: SharingServiceProtocol

    public init(teamSpacesService: TeamSpacesService,
                sharingService: SharingServiceProtocol) {
        self.sharingService = sharingService
        let userGroups = sharingService.pendingUserGroupsPublisher()
        userGroups.combineLatest(teamSpacesService.$selectedSpace) { userGroups, selectedSpace in
            switch selectedSpace {
                case .personal:
                    return []
                case .both, .business:
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
