import SwiftUI
import CoreSharing
import VaultKit
import DashTypes
import Combine
import CorePersonalData

@MainActor
class SharingItemsUserDetailViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var user: SharingItemsUser

    @Published
    var items: [SharedVaultItemInfo<User>] = []

    @Published
    private var actionInProgressIds: Set<Identifier> = []

    @Published
    var alertMessage: String?

    private let sharingService: SharingServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory
    private let detailViewFactory: DetailView.Factory
    let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory

    init(user: SharingItemsUser,
         userUpdatePublisher: AnyPublisher<SharingItemsUser, Never>,
         itemsProvider: SharingToolItemsProvider,
         vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
         gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory,
         detailViewFactory: DetailView.Factory,
         teamSpacesService: TeamSpacesService,
         sharingService: SharingServiceProtocol) {
        self.vaultIconViewModelFactory = vaultIconViewModelFactory
        self.detailViewFactory = detailViewFactory
        self.gravatarIconViewModelFactory = gravatarIconViewModelFactory
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.user = user

        userUpdatePublisher.assign(to: &$user)

        $user.combineLatest(itemsProvider.$vaultItemByIds) { user, vaultItemByIds in
            user.items.compactMap { item in
                guard let vaultItem = vaultItemByIds[item.id] else {
                    return nil
                }

                return SharedVaultItemInfo(vaultItem: vaultItem, group: item.group, recipient: item.recipient)
            }
        }.assign(to: &$items)
    }

    func changePermission(for item: SharedVaultItemInfo<User>, to permission: SharingPermission) {
        trackActionProgress(on: item) {
            do {
                try await self.sharingService.updatePermission(permission, of: item.recipient, in: item.group, loggedItem: item.vaultItem)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage

            }
        }
    }

    func revoke(_ item: SharedVaultItemInfo<User>) {
        trackActionProgress(on: item) {
            do {
                try await self.sharingService.revoke(in: item.group, users: [item.recipient], userGroupMembers: nil, loggedItem: item.vaultItem)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
            }
        }
    }

    func resendInvite(for item: SharedVaultItemInfo<User>) {
        trackActionProgress(on: item) {
            do {
                try await self.sharingService.resendInvites(to: [item.recipient], in: item.group)
                self.alertMessage = L10n.Localizable.kwResendGroupInviteSuccess
            } catch {
                self.alertMessage = L10n.Localizable.kwResendGroupInviteFailure
            }
        }
    }

    private func trackActionProgress(on item: SharedVaultItemInfo<User>, _  action: @escaping () async -> Void) {
        Task {
            actionInProgressIds.insert(item.id)
            await action()
            actionInProgressIds.remove(item.id)
        }
    }

    func makeRowViewModel(item: SharedVaultItemInfo<User>) -> SharedItemInfoRowViewModel<User> {
        return SharedItemInfoRowViewModel(item: item,
                                          inProgress: actionInProgressIds.contains(item.id),
                                          vaultIconViewModelFactory: vaultIconViewModelFactory,
                                          teamSpacesService: teamSpacesService)
    }

    func detailView(for item: SharedVaultItemInfo<User>) -> DetailView {
        detailViewFactory.make(itemDetailViewType: .viewing(item.vaultItem))
    }
 }

 extension SharingItemsUserDetailViewModel {
    static func mock(user: SharingItemsUser,
                     item: VaultItem,
                     itemsProvider: SharingToolItemsProvider,
                     vaultIconViewModelFactory: VaultItemIconViewModel.Factory = .init { .mock(item: $0) },
                     gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory = .init { .mock(email: $0) },
                     teamSpacesService: TeamSpacesService = TeamSpacesService.mock(),
                     sharingService: SharingServiceProtocol = SharingServiceMock()) -> SharingItemsUserDetailViewModel {
        SharingItemsUserDetailViewModel(user: user,
                                        userUpdatePublisher: Empty(completeImmediately: false).eraseToAnyPublisher(),
                                        itemsProvider: itemsProvider,
                                        vaultIconViewModelFactory: vaultIconViewModelFactory,
                                        gravatarIconViewModelFactory: gravatarIconViewModelFactory,
                                        detailViewFactory: .init { _, _ in .mock(item: item) },
                                        teamSpacesService: teamSpacesService,
                                        sharingService: sharingService)
    }

 }
