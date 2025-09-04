import CoreTypes
import Foundation
import GRDB

extension UserGroupUserPair: FetchableRecord {}
extension CollectionUserPair: FetchableRecord {}

extension SQLiteDatabase: SharingOperationsDatabase {
  func save(_ groups: [ItemGroup]) throws {
    guard !groups.isEmpty else {
      return
    }

    try pool.write { db in
      for group in groups {
        try group.save(db)
      }
    }
  }

  func deleteItemGroups(withIds ids: [Identifier]) throws {
    guard !ids.isEmpty else {
      return
    }

    try pool.write { db in
      _ = try ItemGroupInfo.deleteAll(db, ids: ids)
    }
  }

  func fetchItemGroup(withId id: Identifier) throws -> ItemGroup? {
    try pool.read { db in
      return try ItemGroup.fetchOne(db, ItemGroup.request.filter(id: id))
    }
  }

  func fetchItemGroup(withItemId id: Identifier) throws -> ItemGroup? {
    try pool.read { db in
      return try ItemGroup.fetchOne(
        db,
        ItemGroup
          .request
          .having(ItemGroupInfo.itemKeyPairs.filter(Column.id == id).isNotEmpty()))
    }
  }

  func fetchItemGroups(withItemIds ids: [Identifier]) throws -> [ItemGroup] {
    try pool.read { db in
      return try ItemGroup.fetchAll(
        db,
        ItemGroup
          .request
          .having(ItemGroupInfo.itemKeyPairs.filter(ids.contains(Column.id)).isNotEmpty()))
    }
  }

  func fetchAllItemGroups() throws -> [ItemGroup] {
    try pool.read { db in
      return try ItemGroup.fetchAll(db, ItemGroup.request)
    }
  }

  func save(_ collections: [SharingCollection]) throws {
    guard !collections.isEmpty else {
      return
    }

    try pool.write { db in
      for collection in collections {
        try collection.save(db)
      }
    }
  }

  func deleteCollections(withIds ids: [Identifier]) throws {
    guard !ids.isEmpty else {
      return
    }

    try pool.write { db in
      _ = try CollectionInfo.deleteAll(db, ids: ids)
    }
  }

  func fetchCollection(withId id: Identifier) throws -> SharingCollection? {
    try pool.read { db in
      return try SharingCollection.fetchOne(db, SharingCollection.request.filter(id: id))
    }
  }

  func fetchCollections(withIds ids: [Identifier]) throws -> [SharingCollection] {
    try pool.read { db in
      return try SharingCollection.fetchAll(db, SharingCollection.request.filter(ids: ids))
    }
  }

  func fetchAllCollections() throws -> [SharingCollection] {
    try pool.read { db in
      return try SharingCollection.fetchAll(db, SharingCollection.request)
    }
  }

  func save(_ groups: [UserGroup]) throws {
    guard !groups.isEmpty else {
      return
    }

    try pool.write { db in
      for group in groups {
        try group.save(db)
      }
    }
  }

  func deleteUserGroups(withIds ids: [Identifier]) throws {
    guard !ids.isEmpty else {
      return
    }

    try pool.write { db in
      _ = try UserGroupInfo.deleteAll(db, ids: ids)
    }
  }

  func fetchUserGroup(withId id: Identifier) throws -> UserGroup? {
    try pool.read { db in
      return try UserGroup.fetchOne(db, UserGroup.request.filter(id: id))
    }
  }

  func fetchUserGroups(withIds ids: [Identifier]) throws -> [UserGroup] {
    try pool.read { db in
      return try UserGroup.fetchAll(db, UserGroup.request.filter(ids: ids))
    }
  }

  func fetchAllUserGroups() throws -> [UserGroup] {
    try pool.read { db in
      return try UserGroup.fetchAll(db, UserGroup.request)
    }
  }

  func fetchUserGroupUserPair(withGroupId groupId: Identifier, userId: UserId) throws
    -> UserGroupUserPair?
  {
    try pool.read { db in
      let request = User<UserGroup>
        .filter(id: userId, parentGroupId: groupId)
        .including(required: User<UserGroup>.parent.forKey("group"))
        .asRequest(of: UserGroupUserPair.self)
      return try UserGroupUserPair.fetchOne(db, request)
    }
  }

  func fetchCollectionUserPair(withCollectionId collectionId: Identifier, userId: UserId) throws
    -> CollectionUserPair?
  {
    try pool.read { db in
      let request = User<SharingCollection>
        .filter(id: userId, parentGroupId: collectionId)
        .including(required: User<SharingCollection>.parent.forKey("collection"))
        .asRequest(of: CollectionUserPair.self)
      return try CollectionUserPair.fetchOne(db, request)
    }
  }

  func save(_ items: [ItemContentCache]) throws {
    guard !items.isEmpty else {
      return
    }

    try pool.write { db in
      for item in items {
        try item.save(db)
      }
    }
  }

  func deleteItemContentCaches(withIds ids: [Identifier]) throws {
    guard !ids.isEmpty else {
      return
    }

    _ = try pool.write { db in
      try ItemContentCache.deleteAll(db, ids: ids)
    }
  }

  func fetchAllItemContentCaches(withoutIds ids: [Identifier]) throws -> [ItemContentCache] {
    return try pool.read { db in
      return try ItemContentCache.filter(!ids.contains(Column.id)).fetchAll(db)
    }
  }

  func fetchItemTimestamp(forId id: Identifier) throws -> SharingTimestamp? {
    return try pool.read { db -> SharingTimestamp? in
      return
        try SharingTimestamp
        .fetchOne(
          db, ItemContentCache.filter(id: id).select(Column(ItemContentCache.CodingKeys.timestamp)))
    }
  }

  func fetchSummary() throws -> SharingSummary {
    struct TimestampPair: Codable, FetchableRecord, Identifiable {
      enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case timestamp
      }
      let id: Identifier
      let timestamp: SharingTimestamp
    }

    return try pool.read { db in
      let request = ItemContentCache.select(
        TimestampPair.CodingKeys.id, TimestampPair.CodingKeys.timestamp)
      let pairs = try TimestampPair.fetchAll(db, request)
      let items = Dictionary(values: pairs).mapValues(\.timestamp)
      let itemGroups = Dictionary(values: try ItemGroupInfo.fetchAll(db)).mapValues(\.revision)
      let userGroups = Dictionary(values: try UserGroupInfo.fetchAll(db)).mapValues(\.revision)
      let collections = Dictionary(values: try CollectionInfo.fetchAll(db)).mapValues(\.revision)

      return .init(
        items: items,
        itemGroups: itemGroups,
        userGroups: userGroups,
        collections: collections
      )
    }
  }

  func sharingCounts(forUserIds userIds: [UserId], excludingGroupIds: [Identifier]) throws
    -> [UserId: Int]
  {
    struct UserCount: Decodable, FetchableRecord, Identifiable {
      static var countColumn: CodingKey {
        return CodingKeys.count
      }
      let count: Int
      let id: String
    }

    return try pool.read { db in
      let userCounts = try User<ItemGroup>
        .filter(
          userIds.contains(Column.id) && Column.itemGroupId != nil
            && !excludingGroupIds.contains(Column.itemGroupId)
        )
        .group(Column.id)
        .select([count(Column.itemGroupId).forKey(UserCount.countColumn), Column.id])
        .asRequest(of: UserCount.self)
        .fetchAll(db)

      return Dictionary(uniqueKeysWithValues: userCounts.map { ($0.id, $0.count) })
    }
  }
}
