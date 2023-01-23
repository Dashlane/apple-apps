import SwiftUI
import CoreSharing
import VaultKit
import DashTypes
import Combine

@MainActor
class SharingItemsUserGroupDetailViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var userGroup: SharingItemsUserGroup

    @Published
    var items: [SharedVaultItemInfo<UserGroupMember>] = []

    @Published
    private var actionInProgressIds: Set<Identifier> = []

    @Published
    var alertMessage: String?

    private let sharingService: SharingServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory
    let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory

    init(userGroup: SharingItemsUserGroup,
         userGroupUpdatePublisher: AnyPublisher<SharingItemsUserGroup, Never>,
         itemsProvider: SharingToolItemsProvider,
         vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
         gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory,
         teamSpacesService: TeamSpacesService,
         sharingService: SharingServiceProtocol) {
        self.vaultIconViewModelFactory = vaultIconViewModelFactory
        self.gravatarIconViewModelFactory = gravatarIconViewModelFactory
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.userGroup = userGroup

        userGroupUpdatePublisher.assign(to: &$userGroup)

        $userGroup.combineLatest(itemsProvider.$vaultItemByIds) { userGroup, vaultItemByIds in
            userGroup.items.compactMap { item in
                guard let vaultItem = vaultItemByIds[item.id] else {
                    return nil
                }

                return SharedVaultItemInfo(vaultItem: vaultItem, group: item.group, recipient: item.recipient)
            }
        }.assign(to: &$items)
    }

    func changePermission(for item: SharedVaultItemInfo<UserGroupMember>, to permission: SharingPermission) {
        trackActionProgress(on: item) {
            do {
                try await self.sharingService.updatePermission(permission, of: item.recipient, in: item.group, loggedItem: item.vaultItem)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
            }
        }
    }

    func revoke(_ item: SharedVaultItemInfo<UserGroupMember>) {
        trackActionProgress(on: item) {
            do {
                try await self.sharingService.revoke(in: item.group, users: nil, userGroupMembers: [item.recipient], loggedItem: item.vaultItem)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
            }
        }
    }

    private func trackActionProgress(on item: SharedVaultItemInfo<UserGroupMember>, _  action: @escaping () async -> Void) {
        Task {
            actionInProgressIds.insert(item.id)
            await action()
            actionInProgressIds.remove(item.id)
        }
    }

    func makeRowViewModel(item: SharedVaultItemInfo<UserGroupMember>) -> SharedItemInfoRowViewModel<UserGroupMember> {
        return SharedItemInfoRowViewModel(item: item,
                                          inProgress: actionInProgressIds.contains(item.id),
                                          vaultIconViewModelFactory: vaultIconViewModelFactory,
                                          teamSpacesService: teamSpacesService)
    }
 }

extension SharingItemsUserGroupDetailViewModel {
    static func mock(userGroup: SharingItemsUserGroup,
                     itemsProvider: SharingToolItemsProvider,
                     vaultIconViewModelFactory: VaultItemIconViewModel.Factory = .init { .mock(item: $0) },
                     gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory = .init { .mock(email: $0) },
                     teamSpacesService: TeamSpacesService = TeamSpacesService.mock(),
                     sharingService: SharingServiceProtocol = SharingServiceMock()) -> SharingItemsUserGroupDetailViewModel {
        SharingItemsUserGroupDetailViewModel(userGroup: userGroup,
                                             userGroupUpdatePublisher: Empty(completeImmediately: false).eraseToAnyPublisher(),
                                             itemsProvider: itemsProvider,
                                             vaultIconViewModelFactory: vaultIconViewModelFactory,
                                             gravatarIconViewModelFactory: gravatarIconViewModelFactory,
                                             teamSpacesService: teamSpacesService,
                                             sharingService: sharingService)
    }

}
