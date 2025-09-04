import Combine
import CorePersonalData
import CoreSharing
import CoreTypes
import Foundation

public protocol SharingServiceProtocol {
  func pendingUserGroupsPublisher() -> AnyPublisher<[PendingUserGroup], Never>
  func pendingItemGroupsPublisher() -> AnyPublisher<[PendingItemGroup], Never>
  func pendingCollectionsPublisher() -> AnyPublisher<[PendingCollection], Never>
  func sharingCollectionsPublisher() -> AnyPublisher<[SharedCollectionItems], Never>
  func sharingUserGroupsPublisher() -> AnyPublisher<[SharingEntitiesUserGroup], Never>
  func sharingUsersPublisher() -> AnyPublisher<[SharingEntitiesUser], Never>
  func sharingMembers(forItemId id: Identifier) -> AnyPublisher<ItemSharingMembers?, Never>
  func sharingMembers(forCollectionId id: Identifier) -> AnyPublisher<
    CollectionSharingMembers?, Never
  >

  func pendingItemsPublisher() -> AnyPublisher<[Identifier: VaultItem], Never>
  func update(spaceId: String, toPendingItem item: VaultItem)

  func isReadyPublisher() -> AnyPublisher<Bool, Never>

  func getTeamLogins() async throws -> [String]

  func accept(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws
  func refuse(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws

  func accept(_ groupInfo: UserGroupInfo) async throws
  func refuse(_ groupInfo: UserGroupInfo) async throws

  func accept(_ collectionInfo: CollectionInfo) async throws
  func refuse(_ collectionInfo: CollectionInfo) async throws

  func revoke(
    in group: ItemGroupInfo,
    users: [User<ItemGroup>]?,
    userGroupMembers: [UserGroupMember<ItemGroup>]?,
    loggedItem: VaultItem) async throws

  func revoke(
    in collection: CollectionInfo,
    users: [User<SharingCollection>]?,
    userGroupMembers: [UserGroupMember<SharingCollection>]?
  ) async throws

  func forceRevoke(_ items: [PersonalDataCodable]) async throws

  func updatePermission(
    _ permission: SharingPermission,
    of user: User<ItemGroup>,
    in group: ItemGroupInfo,
    loggedItem: VaultItem) async throws
  func updatePermission(
    _ permission: SharingPermission,
    of userGroupMember: UserGroupMember<ItemGroup>,
    in group: ItemGroupInfo,
    loggedItem: VaultItem) async throws

  func updatePermission(
    _ permission: SharingPermission,
    of user: User<SharingCollection>,
    in collection: CollectionInfo
  ) async throws

  func updatePermission(
    _ permission: SharingPermission,
    of userGroupMember: UserGroupMember<SharingCollection>,
    in collection: CollectionInfo
  ) async throws

  func resendInvites(to users: [User<ItemGroup>], in group: ItemGroupInfo) async throws

  func share(
    _ items: [VaultItem],
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    limitPerUser: Int?) async throws

  func share(
    _ collections: [VaultCollection],
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission
  ) async throws

  func addItemsToCollection(withId collectionId: Identifier, itemIds: [Identifier]) async throws
  func removeItemsFromCollection(withId collectionId: Identifier, itemIds: [Identifier])
    async throws

  func renameCollection(withId collectionId: Identifier, name: String) async throws
  func deleteCollection(withId collectionId: Identifier) async throws
}
