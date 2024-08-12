import DashTypes
import Foundation
import GRDB

extension ItemSharingMembers: FetchableRecord {}
extension CollectionSharingMembers: FetchableRecord {}

extension SQLiteDatabase: SharingUIDatabase {
  public typealias ItemSharingSequence = AsyncValueObservation<ItemSharingMembers?>
  public typealias CollectionSharingSequence = AsyncValueObservation<CollectionSharingMembers?>
  public typealias SharingEntitiesUserGroupSequence = AsyncValueObservation<
    [SharingEntitiesUserGroup]
  >
  public typealias SharingEntitiesUserSequence = AsyncValueObservation<[SharingEntitiesUser]>
  public typealias SharingCollectionsSequence = AsyncValueObservation<[SharedCollectionItems]>
  public typealias PendingItemGroupsSequence = AsyncValueObservation<[PendingItemGroup]>
  public typealias PendingCollectionGroupsSequence = AsyncValueObservation<[PendingCollection]>
  public typealias PendingUserGroupsSequence = AsyncValueObservation<[PendingUserGroup]>

  public func sharingMembers(forItemId id: Identifier) -> ItemSharingSequence {
    let itemGroup = try? fetchItemGroup(withItemId: id)

    return ValueObservation.tracking { db in
      let collectionsRequest = CollectionInfo.filter(
        ids: itemGroup?.collectionMembers.map(\.id) ?? []
      )
      .including(all: CollectionInfo.users.order([Column.id]))
      .including(all: CollectionInfo.userGroupMembers.order(Column.name))
      .asRequest(of: CollectionSharingMembers.self)

      let collections = try CollectionSharingMembers.fetchAll(db, collectionsRequest)

      var users = itemGroup?.users ?? []
      collections.forEach { users.appendCollectionUsers(contentsOf: $0.users) }

      var userGroupMembers = itemGroup?.userGroupMembers ?? []
      collections.forEach {
        userGroupMembers.appendCollectionUserGroups(contentsOf: $0.userGroupMembers)
      }

      let collectionMembers = itemGroup?.collectionMembers ?? []

      return itemGroup.map {
        ItemSharingMembers(
          itemGroupInfo: $0.info,
          users: users,
          userGroupMembers: userGroupMembers,
          collectionMembers: collectionMembers
        )
      }
    }.values(in: pool)
  }

  public func sharingMembers(forCollectionId id: Identifier) -> CollectionSharingSequence {
    let request =
      CollectionInfo
      .filter(id: id)
      .including(all: CollectionInfo.users.order([Column.id]))
      .including(all: CollectionInfo.userGroupMembers.order([Column.name]))
      .asRequest(of: CollectionSharingMembers.self)

    return ValueObservation.tracking { db in
      return try CollectionSharingMembers.fetchOne(db, request)
    }.values(in: pool)
  }

  public func sharingUserGroups(for currentUserId: UserId) -> SharingEntitiesUserGroupSequence {
    let userGroupRequest =
      UserGroupInfo
      .having(UserGroupInfo.users.filter(id: currentUserId).filter(status: .accepted).isNotEmpty())
      .including(all: UserGroupInfo.users)

    let itemGroupsRequest = ItemGroupInfo.havingAcceptedUser(with: currentUserId)
      .including(
        all: ItemGroupInfo.userGroupMembers.filter(status: [.pending, .accepted]).forKey(
          FetchedUItemGroup<User<ItemGroup>>.CodingKeys.members)
      )
      .including(
        all: ItemGroupInfo.itemIds.forKey(
          FetchedUItemGroup<UserGroupMember<ItemGroup>>.CodingKeys.itemIds)
      )
      .asRequest(of: FetchedUItemGroup<UserGroupMember<ItemGroup>>.self)

    let collectionsRequest = CollectionInfo.havingAcceptedUser(with: currentUserId)
      .including(
        all: CollectionInfo.userGroupMembers.filter(status: [.pending, .accepted]).forKey(
          FetchedUICollection<User<SharingCollection>>.CodingKeys.members)
      )
      .asRequest(of: FetchedUICollection<User<SharingCollection>>.self)

    return ValueObservation.tracking { db in
      let userGroups = try UserGroup.fetchAll(db, userGroupRequest).map { userGroup in
        SharingEntitiesUserGroup(
          id: userGroup.id,
          name: userGroup.info.name,
          isMember: userGroup.users.contains { $0.id == currentUserId },
          users: userGroup.users
        )
      }
      var userGroupsById = Dictionary(values: userGroups)

      let itemGroups = try FetchedUItemGroup<UserGroupMember<ItemGroup>>.fetchAll(
        db, itemGroupsRequest)
      let collections = try FetchedUICollection<UserGroupMember<SharingCollection>>.fetchAll(
        db, collectionsRequest)

      for group in itemGroups {
        for userGroupMember in group.members {
          userGroupsById[userGroupMember.id]?
            .items += group.sharedItems(for: userGroupMember)
        }
        guard
          let linkableItemGroup = try ItemGroup.fetchOne(
            db, ItemGroup.request.filter(id: group.itemGroupInfo.id))
        else { continue }
        var userGroupsThroughCollections: [UserGroupMember<SharingCollection>] = []
        let collectionsSharingItemGroup = collections.filter { collection in
          linkableItemGroup.collectionMembers.contains(where: {
            $0.id == collection.collectionInfo.id
          })
        }
        for collection in collectionsSharingItemGroup {
          for userGroupMemberFromCollection in collection.members {
            guard
              !userGroupsThroughCollections.contains(where: {
                $0.id == userGroupMemberFromCollection.id
              })
            else { continue }
            userGroupsThroughCollections.append(userGroupMemberFromCollection)
          }
        }
        for userGroupMember in userGroupsThroughCollections {
          userGroupsById[userGroupMember.id]?
            .items += group.sharedItems(for: userGroupMember.asItemGroupUserGroupMember)
        }
      }

      for collection in collections {
        for userGroupMember in collection.members {
          userGroupsById[userGroupMember.id]?
            .collections
            .append(
              .init(
                id: collection.collectionInfo.id, info: collection.collectionInfo,
                recipient: userGroupMember))
        }
      }

      return userGroupsById.values
        .sorted { $0.name < $1.name }
    }.values(in: pool)
  }
  public func sharingUsers(for currentUserId: UserId) -> SharingEntitiesUserSequence {
    let itemsRequest = ItemGroupInfo.havingAcceptedUser(with: currentUserId)
      .including(
        all: ItemGroupInfo.users.filterOut(id: currentUserId).filter(status: [.pending, .accepted])
          .forKey(FetchedUItemGroup<User<ItemGroup>>.CodingKeys.members)
      )
      .including(
        all: ItemGroupInfo.itemIds.forKey(FetchedUItemGroup<User<ItemGroup>>.CodingKeys.itemIds)
      )
      .asRequest(of: FetchedUItemGroup<User<ItemGroup>>.self)

    let collectionsRequest = CollectionInfo.havingAcceptedUser(with: currentUserId)
      .including(
        all: CollectionInfo.users.filterOut(id: currentUserId).filter(status: [.pending, .accepted])
          .forKey(FetchedUICollection<User<SharingCollection>>.CodingKeys.members)
      )
      .asRequest(of: FetchedUICollection<User<SharingCollection>>.self)

    return ValueObservation.tracking { db in
      let groups = try FetchedUItemGroup<User<ItemGroup>>.fetchAll(db, itemsRequest)
      let collections = try FetchedUICollection<User<SharingCollection>>.fetchAll(
        db, collectionsRequest)

      var sharingItemsCollectionsUserByIds = [UserId: SharingEntitiesUser]()
      for group in groups {
        for user in group.members {
          sharingItemsCollectionsUserByIds[user.id, default: SharingEntitiesUser(id: user.id)]
            .items += group.sharedItems(for: user)
        }
        guard
          let linkableItemGroup = try ItemGroup.fetchOne(
            db, ItemGroup.request.filter(id: group.itemGroupInfo.id))
        else { continue }
        var usersThroughCollections: [User<SharingCollection>] = []
        let collectionsSharingItemGroup = collections.filter { collection in
          linkableItemGroup.collectionMembers.contains(where: {
            $0.id == collection.collectionInfo.id
          })
        }
        for collection in collectionsSharingItemGroup {
          for userFromCollection in collection.members {
            guard !usersThroughCollections.contains(where: { $0.id == userFromCollection.id })
            else { continue }
            usersThroughCollections.append(userFromCollection)
          }
        }
        for user in usersThroughCollections {
          sharingItemsCollectionsUserByIds[user.id, default: SharingEntitiesUser(id: user.id)]
            .items += group.sharedItems(for: user.asItemGroupUser)
        }
      }

      for collection in collections {
        for user in collection.members {
          sharingItemsCollectionsUserByIds[user.id, default: SharingEntitiesUser(id: user.id)]
            .collections
            .append(
              .init(
                id: collection.collectionInfo.id, info: collection.collectionInfo, recipient: user))
        }
      }

      return sharingItemsCollectionsUserByIds.values
        .filter { !$0.items.isEmpty || !$0.collections.isEmpty }
        .sorted { $0.id < $1.id }
    }.values(in: pool)
  }

  public func sharingCollections(for currentUserId: UserId) -> SharingCollectionsSequence {
    let itemsRequest =
      ItemGroupInfo
      .including(
        all: ItemGroupInfo.collectionMembers.forKey(
          FetchedUItemGroup<CollectionMember>.CodingKeys.members)
      )
      .including(
        all: ItemGroupInfo.itemIds.forKey(FetchedUItemGroup<CollectionMember>.CodingKeys.itemIds)
      )
      .asRequest(of: FetchedUItemGroup<CollectionMember>.self)

    let collectionsRequest = CollectionInfo.havingAcceptedUser(with: currentUserId)
      .including(
        all: CollectionInfo.users.filter(status: [.pending, .accepted]).forKey(
          FetchedUICollection<User<SharingCollection>>.CodingKeys.members)
      )
      .asRequest(of: FetchedUICollection<User<SharingCollection>>.self)

    return ValueObservation.tracking { db in
      let groups = try FetchedUItemGroup<CollectionMember>.fetchAll(db, itemsRequest)
      let collections = try FetchedUICollection<User<SharingCollection>>.fetchAll(
        db, collectionsRequest)

      var sharedCollectionItems: [SharedCollectionItems] = []

      for collection in collections {
        let items = groups.filter {
          $0.members.contains(where: { member in member.id == collection.collectionInfo.id })
        }

        sharedCollectionItems.append(
          .init(
            collection: collection.collectionInfo,
            itemIds: items.map(\.itemIds).flatMap { $0 },
            permission: collection.members.first(where: { $0.id == currentUserId })?.permission
              ?? .limited
          )
        )
      }

      return sharedCollectionItems
    }.values(in: pool)
  }

  public func pendingItemGroups(for userId: UserId) -> PendingItemGroupsSequence {
    let request =
      ItemGroupInfo
      .orderByPrimaryKey()
      .having(ItemGroupInfo.users.filter(id: userId).filter(status: .pending).isNotEmpty())
      .including(all: ItemGroupInfo.itemIds.forKey(PendingItemGroup.CodingKeys.itemIds))
      .including(
        all: ItemGroupInfo.users.filter(id: userId).select(
          Column(PendingItemGroup.CodingKeys.referrer)
        ).forKey(PendingItemGroup.CodingKeys.referrer)
      )
      .asRequest(of: PendingItemGroup.self)

    return ValueObservation.tracking { db in
      return try PendingItemGroup.fetchAll(db, request).filter { !$0.itemIds.isEmpty }
    }.values(in: pool)
  }

  public func pendingCollections(for userId: UserId) -> PendingCollectionGroupsSequence {
    let request =
      CollectionInfo
      .order(Column.name)
      .having(CollectionInfo.users.filter(id: userId).filter(status: .pending).isNotEmpty())
      .including(
        all: CollectionInfo.users.filter(id: userId).select(
          Column(PendingCollection.CodingKeys.referrer)
        ).forKey(PendingCollection.CodingKeys.referrer)
      )
      .asRequest(of: PendingCollection.self)

    return ValueObservation.tracking { db in
      return try PendingCollection.fetchAll(db, request)
    }.values(in: pool)
  }

  public func pendingUserGroups(for userId: UserId) -> PendingUserGroupsSequence {
    let request =
      UserGroupInfo
      .order(Column.name)
      .having(UserGroupInfo.users.filter(id: userId).filter(status: .pending).isNotEmpty())
      .including(
        all: UserGroupInfo.users.filter(id: userId).select(
          Column(PendingUserGroup.CodingKeys.referrer)
        ).forKey(PendingUserGroup.CodingKeys.referrer)
      )
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

private struct FetchedUItemGroup<Member: SharingGroupMember & Decodable & Identifiable>: Decodable,
  FetchableRecord
where Member.Group == ItemGroup {
  enum CodingKeys: String, CodingKey {
    case itemGroupInfo
    case members
    case itemIds
  }

  let itemGroupInfo: ItemGroupInfo
  let members: [Member]
  let itemIds: [Identifier]
}

extension FetchedUItemGroup {
  func sharedItems(for recipient: Member) -> [SharedEntityInfo<Member>] {
    itemIds.map { .init(id: $0, info: itemGroupInfo, recipient: recipient) }
  }
}

private struct FetchedUICollection<Member: SharingGroupMember & Decodable & Identifiable>:
  Decodable, FetchableRecord
where Member.Group == SharingCollection {
  enum CodingKeys: String, CodingKey {
    case collectionInfo
    case members
  }

  let collectionInfo: CollectionInfo
  let members: [Member]
}

extension User<SharingCollection> {
  fileprivate var asItemGroupUser: User<ItemGroup> {
    User<ItemGroup>(
      id: id,
      parentGroupId: parentGroupId,
      userGroupId: userGroupId,
      itemGroupId: itemGroupId,
      collectionId: collectionId,
      referrer: referrer,
      status: status,
      encryptedGroupKey: encryptedGroupKey,
      permission: permission,
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature,
      rsaStatus: rsaStatus
    )
  }
}

extension Array where Element == User<ItemGroup> {
  mutating func appendCollectionUser(_ collectionUser: User<SharingCollection>) {
    if let itemGroupUserIndex = firstIndex(where: { $0.id == collectionUser.id }) {
      let itemGroupUser = self[itemGroupUserIndex]
      if itemGroupUser.permission != collectionUser.permission,
        case .admin = collectionUser.permission
      {
        remove(at: itemGroupUserIndex)
        append(collectionUser.asItemGroupUser)
      }
    } else {
      append(collectionUser.asItemGroupUser)
    }
  }

  mutating func appendCollectionUsers(contentsOf newElements: [User<SharingCollection>]) {
    newElements.forEach { appendCollectionUser($0) }
  }
}

extension UserGroupMember<SharingCollection> {
  fileprivate var asItemGroupUserGroupMember: UserGroupMember<ItemGroup> {
    UserGroupMember<ItemGroup>(
      id: id,
      collectionId: collectionId ?? .init(),
      name: name,
      status: status,
      permission: permission,
      encryptedGroupKey: encryptedGroupKey,
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature
    )
  }
}

extension Array where Element == UserGroupMember<ItemGroup> {
  mutating func appendCollectionUserGroup(_ collectionUser: UserGroupMember<SharingCollection>) {
    if let itemGroupUserIndex = firstIndex(where: { $0.id == collectionUser.id }) {
      let itemGroupUser = self[itemGroupUserIndex]
      if itemGroupUser.permission != collectionUser.permission,
        case .admin = collectionUser.permission
      {
        remove(at: itemGroupUserIndex)
        append(collectionUser.asItemGroupUserGroupMember)
      }
    } else {
      append(collectionUser.asItemGroupUserGroupMember)
    }
  }

  mutating func appendCollectionUserGroups(
    contentsOf newElements: [UserGroupMember<SharingCollection>]
  ) {
    newElements.forEach { appendCollectionUserGroup($0) }
  }
}
