import Foundation
import GRDB
import DashTypes

extension ItemSharingMembers: FetchableRecord { }

extension SQLiteDatabase: SharingUIDatabase {
        public typealias ItemSharingSequence = AsyncValueObservation<ItemSharingMembers?>
    public typealias SharingItemsUserGroupSequence = AsyncValueObservation<[SharingItemsUserGroup]>
    public typealias SharingItemsUserSequence = AsyncValueObservation<[SharingItemsUser]>
    public typealias PendingItemGroupsSequence = AsyncValueObservation<[PendingItemGroup]>
    public typealias PendingUserGroupsSequence = AsyncValueObservation<[PendingUserGroup]>

        public func sharingMembers(forItemId id: Identifier) -> ItemSharingSequence {
        let request = ItemGroupInfo
                    .having(ItemGroupInfo.itemKeyPairs.filter(id: id).isNotEmpty())
                    .including(all: ItemGroupInfo.users.order([Column.id]))
            .including(all: ItemGroupInfo.userGroupMembers.order(Column.name))
            .asRequest(of: ItemSharingMembers.self)
        
        return ValueObservation.tracking { db in
            return try ItemSharingMembers.fetchOne(db, request)
        }.values(in: pool)
    }

        public func sharingUserGroups(for currentUserId: UserId) -> SharingItemsUserGroupSequence {
        let userGroupRequest = UserGroupInfo
            .having(UserGroupInfo.users.filter(id: currentUserId).filter(status: .accepted).isNotEmpty())
            .including(all: UserGroupInfo.users)

                let itemGroupsRequest = ItemGroupInfo.havingAcceptedUser(with: currentUserId)
                    .including(all: ItemGroupInfo.userGroupMembers.filter(status: [.pending, .accepted]).forKey(FetchedUItemGroup<User>.CodingKeys.members))
                    .including(all: ItemGroupInfo.itemIds.forKey(FetchedUItemGroup<UserGroupMember>.CodingKeys.itemIds))
            .asRequest(of: FetchedUItemGroup<UserGroupMember>.self)
        
        return ValueObservation.tracking { db in
            let userGroups = try UserGroup.fetchAll(db, userGroupRequest).map { userGroup in
                SharingItemsUserGroup(id: userGroup.id,
                                      name: userGroup.info.name,
                                      isMember: userGroup.users.contains { $0.id == currentUserId },
                                      users: userGroup.users)
            }
            var userGroupsById = Dictionary(values: userGroups)
            
            let itemGroups = try FetchedUItemGroup<UserGroupMember>.fetchAll(db, itemGroupsRequest)

                        for group in itemGroups {
                for userGroupMember in group.members {
                    userGroupsById[userGroupMember.id]?
                        .items += group.sharedItems(for: userGroupMember)
                }
            }
                        return userGroupsById.values.sorted {
                $0.name < $1.name
            }
        }.values(in: pool)
    }
    
        public func sharingUsers(for currentUserId: UserId) -> SharingItemsUserSequence {
                let request = ItemGroupInfo.havingAcceptedUser(with: currentUserId)
                    .including(all: ItemGroupInfo.users.filterOut(id: currentUserId).filter(status: [.pending, .accepted]).forKey(FetchedUItemGroup<User>.CodingKeys.members))
                    .including(all: ItemGroupInfo.itemIds.forKey(FetchedUItemGroup<User>.CodingKeys.itemIds))
            .asRequest(of: FetchedUItemGroup<User>.self)
        
        return ValueObservation.tracking { db in
            let groups = try FetchedUItemGroup<User>.fetchAll(db, request)
            
                        var sharingItemsUserByIds = [UserId: SharingItemsUser]()
            for group in groups {
                for user in group.members {
                    sharingItemsUserByIds[user.id, default: SharingItemsUser(id: user.id)]
                        .items += group.sharedItems(for: user)
                }
            }
            
                        return sharingItemsUserByIds.values
                .filter {
                    !$0.items.isEmpty
                }
                .sorted {
                $0.id < $1.id
            }
        }.values(in: pool)
    }
    
        public func pendingItemGroups(for userId: UserId) -> PendingItemGroupsSequence {
        let request = ItemGroupInfo
            .orderByPrimaryKey()
                    .having(ItemGroupInfo.users.filter(id: userId).filter(status: .pending).isNotEmpty())
                    .including(all: ItemGroupInfo.itemIds.forKey(PendingItemGroup.CodingKeys.itemIds))
                    .including(all: ItemGroupInfo.users.filter(id: userId).select(Column(PendingItemGroup.CodingKeys.referrer)).forKey(PendingItemGroup.CodingKeys.referrer))
            .asRequest(of: PendingItemGroup.self)
        
        return ValueObservation.tracking { db in
            return try PendingItemGroup.fetchAll(db, request).filter { !$0.itemIds.isEmpty }
        }.values(in: pool)
    }
    
        public func pendingUserGroups(for userId: UserId) -> PendingUserGroupsSequence {
        let request = UserGroupInfo
            .order(Column.name)
                    .having(UserGroupInfo.users.filter(id: userId).filter(status: .pending).isNotEmpty())
                    .including(all: UserGroupInfo.users.filter(id: userId).select(Column(PendingUserGroup.CodingKeys.referrer)).forKey(PendingUserGroup.CodingKeys.referrer))
            .asRequest(of: PendingUserGroup.self)

        return ValueObservation.tracking { db in
            return try PendingUserGroup.fetchAll(db, request)
        }.values(in: pool)
    }
}

extension Column {
        static let name = Column("name")
}

extension AssociationToMany {
        func isNotEmpty() -> AssociationAggregate<OriginRowDecoder> {
        self.isEmpty == false
    }
}

fileprivate struct FetchedUItemGroup<Member: SharingGroupMember & Decodable & Identifiable>: Decodable, FetchableRecord {
    enum CodingKeys: String, CodingKey {
        case itemGroupInfo
        case members
        case itemIds
    }
    
    let itemGroupInfo: ItemGroupInfo
    let members: [Member]
    let itemIds: [Identifier]
}

fileprivate extension FetchedUItemGroup {
    func sharedItems<Member: SharingGroupMember>(for recipient: Member) -> [SharedItemInfo<Member>]{
         itemIds.map { .init(id: $0, group: itemGroupInfo, recipient: recipient) }
    }
}

