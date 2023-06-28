import Foundation
import DashTypes
import CoreSharing
import Combine
import CorePersonalData

public protocol SharingServiceProtocol {
    func pendingUserGroupsPublisher() -> AnyPublisher<[PendingUserGroup], Never>
    func pendingItemGroupsPublisher() -> AnyPublisher<[PendingItemGroup], Never>
    func sharingUserGroupsPublisher() -> AnyPublisher<[SharingItemsUserGroup], Never>
    func sharingUsersPublisher() -> AnyPublisher<[SharingItemsUser], Never>
    func sharingMembers(forItemId id: Identifier) -> AnyPublisher<ItemSharingMembers?, Never>

    func pendingItemsPublisher() -> AnyPublisher<[Identifier: VaultItem], Never>
    func update(spaceId: String, toPendingItem item: VaultItem)

    func isReadyPublisher() -> AnyPublisher<Bool, Never>

    func accept(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws
    func refuse(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws

    func accept(_ groupInfo: UserGroupInfo) async throws
    func refuse(_ groupInfo: UserGroupInfo) async throws

    func revoke(in group: ItemGroupInfo,
                users: [User]?,
                userGroupMembers: [UserGroupMember]?,
                loggedItem: VaultItem) async throws

    func updatePermission(_ permission: SharingPermission,
                          of user: User,
                          in group: ItemGroupInfo,
                          loggedItem: VaultItem) async throws
    func updatePermission(_ permission: SharingPermission,
                          of userGroupMember: UserGroupMember,
                          in group: ItemGroupInfo,
                          loggedItem: VaultItem)  async throws

    func resendInvites(to users: [User], in group: ItemGroupInfo) async throws

    func share(_ items: [VaultItem],
               recipients: [String],
               userGroupIds: [Identifier],
               permission: SharingPermission,
               limitPerUser: Int?) async throws
}
