import Foundation
import DashTypes

protocol SharingOperationsDatabase {
    func save(_ groups: [ItemGroup]) throws
    func deleteItemGroups(withIds ids: [Identifier]) throws
    func fetchItemGroup(withId: Identifier) throws -> ItemGroup?
    func fetchItemGroup(withItemId id: Identifier) throws -> ItemGroup?
    func fetchItemGroups(withItemIds ids: [Identifier]) throws -> [ItemGroup]
    func fetchAllItemGroups() throws -> [ItemGroup]

    func save(_ groups: [UserGroup]) throws
    func deleteUserGroups(withIds ids: [Identifier]) throws
    func fetchUserGroup(withId: Identifier) throws -> UserGroup?
    func fetchUserGroups(withIds ids: [Identifier]) throws -> [UserGroup]
    func fetchAllUserGroups() throws -> [UserGroup]
    
    func fetchUserGroupUserPair(withGroupId groupId: Identifier, userId: UserId) throws -> UserGroupUserPair?

    func save(_ groups: [ItemContentCache]) throws
    func deleteItemContentCaches(withIds ids: [Identifier]) throws
    func fetchAllItemContentCaches(withoutIds ids: [Identifier]) throws -> [ItemContentCache]
    func fetchItemTimestamp(forId id: Identifier) throws -> SharingTimestamp?
    
    func fetchSummary() throws -> SharingSummary
    
    func sharingCounts(forUserIds userIds: [UserId], excludingGroupIds: [Identifier]) throws -> [UserId: Int]
}


struct UserGroupUserPair: Decodable {
    let user: User
    let group: UserGroupInfo
}
