import Foundation
import CoreSharing
import Combine
import SwiftUI
import VaultKit
import DashTypes
import CorePersonalData
import CoreSession

@MainActor
class SharingMembersDetailViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {
    @Published
    var isSharingReady: Bool = false

    @Published
    var members: ItemSharingMembers

    @Published
    var permission: SharingPermission

    @Published
    var alertMessage: String?

    @Published
    var groupActionInProgressIds: Set<Identifier> = []

    @Published
    var userActionInProgressIds: Set<UserId> = []

    let gravatarViewModelFactory: GravatarIconViewModel.SecondFactory
    let shareButtonModelFactory: ShareButtonViewModel.Factory
    let sharingService: SharingServiceProtocol
    let currentUserId: UserId
    private let item: VaultItem

    init(members: ItemSharingMembers,
         item: VaultItem,
         session: Session,
         personalDataBD: ApplicationDatabase,
         gravatarViewModelFactory: GravatarIconViewModel.SecondFactory,
         shareButtonModelFactory: ShareButtonViewModel.Factory,
         sharingService: SharingServiceProtocol) {
        self.members = members
        self.permission = item.metadata.sharingPermission ?? .admin
        self.gravatarViewModelFactory = gravatarViewModelFactory
        self.shareButtonModelFactory = shareButtonModelFactory
        self.sharingService = sharingService
        self.item = item
        currentUserId = session.login.email
        personalDataBD.metadataPublisher(for: item.id)
            .ignoreError()
            .compactMap { $0.sharingPermission }
            .receive(on: DispatchQueue.main)
            .assign(to: &$permission)

        sharingService.isReadyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSharingReady)
        sharingService.sharingMembers(forItemId: item.id)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: &$members)
    }

    func makeShareButtonModelFactory() -> ShareButtonViewModel {
        shareButtonModelFactory.make(items: [self.item])
    }
}

extension SharingMembersDetailViewModel {
    private func trackUserGroupActionProgress(on userGroup: UserGroupMember, _  action: @escaping () async -> Void) {
        Task {
            groupActionInProgressIds.insert(userGroup.id)
            await action()
            groupActionInProgressIds.remove(userGroup.id)
        }
    }

    func changePermission(for userGroup: UserGroupMember, to permission: SharingPermission) {
        trackUserGroupActionProgress(on: userGroup) {
            do {
                try await self.sharingService.updatePermission(permission, of: userGroup, in: self.members.itemGroupInfo, loggedItem: self.item)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage

            }
        }
    }

    func revoke(_ userGroup: UserGroupMember) {
        trackUserGroupActionProgress(on: userGroup) {
            do {
                try await self.sharingService.revoke(in: self.members.itemGroupInfo, users: nil, userGroupMembers: [userGroup], loggedItem: self.item)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
            }
        }
    }
}
extension SharingMembersDetailViewModel {
    private func trackUserActionProgress(on user: User, _  action: @escaping () async -> Void) {
        Task {
            userActionInProgressIds.insert(user.id)
            await action()
            userActionInProgressIds.remove(user.id)
        }
    }

    func changePermission(for user: User, to permission: SharingPermission) {
        trackUserActionProgress(on: user) {
            do {
                try await self.sharingService.updatePermission(permission, of: user, in: self.members.itemGroupInfo, loggedItem: self.item)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage

            }
        }
    }

    func revoke(_ user: User) {
        trackUserActionProgress(on: user) {
            do {
                try await self.sharingService.revoke(in: self.members.itemGroupInfo, users: [user], userGroupMembers: nil, loggedItem: self.item)
            } catch {
                self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
            }
        }
    }

    func resendInvite(for user: User) {
        trackUserActionProgress(on: user) {
            do {
                try await self.sharingService.resendInvites(to: [user], in: self.members.itemGroupInfo)
                self.alertMessage = L10n.Localizable.kwResendGroupInviteSuccess
            } catch {
                self.alertMessage = L10n.Localizable.kwResendGroupInviteFailure
            }
        }
    }
}
