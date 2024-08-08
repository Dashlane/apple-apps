import CyrilKit
import DashTypes
import Foundation

@SharingActor
class GroupKeyProvider {
  private struct Cache {
    let key: SymmetricKey
    let revision: SharingRevision
  }

  let userId: UserId
  let userKeyProvider: UserKeyProvider
  let database: SharingOperationsDatabase
  let cryptoProvider: SharingCryptoProvider
  private var groupKeysCache: [Identifier: Cache] = [:]

  init(
    userId: UserId,
    userKeyProvider: @escaping UserKeyProvider,
    database: SharingOperationsDatabase,
    cryptoProvider: SharingCryptoProvider
  ) {
    self.userId = userId
    self.userKeyProvider = userKeyProvider
    self.database = database
    self.cryptoProvider = cryptoProvider
  }

  func groupKey(for collection: SharingCollection) throws -> SharingSymmetricKey<SharingCollection>?
  {
    return try cache(forId: collection.id, revision: collection.info.revision) {
      () throws -> SharingSymmetricKey<SharingCollection>? in
      if let user = collection.user(with: userId) {
        return try groupKey(for: user)
      } else {
        return try collection.userGroupMembers.lazy.compactMap {
          try groupKey(for: $0)
        }.first
      }
    }
  }

  func privateKey(for collection: SharingCollection) throws -> SharingPrivateKey<SharingCollection>?
  {
    guard let groupKey = try groupKey(for: collection) else {
      return nil
    }

    return try collection.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
  }

  func groupKey(for group: ItemGroup) throws -> SharingSymmetricKey<ItemGroup>? {
    return try cache(forId: group.id, revision: group.info.revision) {
      () throws -> SharingSymmetricKey<ItemGroup>? in
      if let user = group.user(with: userId) {
        return try groupKey(for: user)
      } else if let userGroupMemberKey = try group.userGroupMembers.lazy.compactMap({
        try groupKey(for: $0)
      }).first {
        return userGroupMemberKey
      } else {
        return try group.collectionMembers.lazy.compactMap {
          return try groupKey(for: $0)
        }.first
      }
    }
  }

  func groupKey(for group: UserGroup) throws -> SharingSymmetricKey<UserGroup>? {
    return try cache(forId: group.id, revision: group.info.revision) {
      () throws -> SharingSymmetricKey<UserGroup>? in
      guard let user = group.user(with: userId) else {
        return nil
      }

      return try groupKey(for: user)
    }
  }

  private func groupKey<Group: SharingGroup>(for user: User<Group>) throws -> SharingSymmetricKey<
    Group
  >? {
    guard user.status.isAcceptedOrPending else {
      return nil
    }
    let key = try self.userKeyProvider().privateKey
    return try user.groupKey(using: key, cryptoProvider: cryptoProvider)
  }

  func privateKey(for userGroup: UserGroup) throws -> SharingPrivateKey<UserGroup>? {
    guard let groupKey = try groupKey(for: userGroup) else {
      return nil
    }

    return try userGroup.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
  }

  func keys<Group: SharingGroup>(for userGroupMember: UserGroupMember<Group>) throws -> (
    groupKey: SharingSymmetricKey<Group>, privateKey: SharingPrivateKey<UserGroup>
  )? {
    guard userGroupMember.status.isAcceptedOrPending else {
      return nil
    }

    guard
      let pair = try database.fetchUserGroupUserPair(
        withGroupId: userGroupMember.id, userId: userId),
      pair.user.status == .accepted,
      let groupKey = try cache(
        forId: pair.group.id, revision: pair.group.revision,
        {
          try self.groupKey(for: pair.user)
        })
    else {
      return nil
    }

    let privateKey = try pair.group.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
    let itemGroupKey = try userGroupMember.groupKey(
      using: privateKey, cryptoProvider: cryptoProvider)

    return (groupKey: itemGroupKey, privateKey: privateKey)
  }

  private func groupKey<Group: SharingGroup>(for userGroupMember: UserGroupMember<Group>) throws
    -> SharingSymmetricKey<Group>?
  {
    guard userGroupMember.status.isAcceptedOrPending else {
      return nil
    }

    guard let keys = try keys(for: userGroupMember) else {
      return nil
    }

    return keys.groupKey
  }

  func keys(for collectionMember: CollectionMember) throws -> (
    itemGroupKey: SharingSymmetricKey<ItemGroup>, privateKey: SharingPrivateKey<SharingCollection>
  )? {

    guard collectionMember.status.isAcceptedOrPending,
      let collection = try database.fetchCollection(withId: collectionMember.id),
      let collectionKey = try groupKey(for: collection)
    else {
      return nil
    }

    let privateKey = try collection.privateKey(using: collectionKey, cryptoProvider: cryptoProvider)
    let itemGroupKey = try collectionMember.groupKey(
      using: privateKey, cryptoProvider: cryptoProvider)

    return (itemGroupKey: itemGroupKey, privateKey: privateKey)
  }

  private func groupKey(for collectionMember: CollectionMember) throws -> SharingSymmetricKey<
    ItemGroup
  >? {
    guard collectionMember.status.isAcceptedOrPending else {
      return nil
    }

    guard let keys = try keys(for: collectionMember) else {
      return nil
    }

    return keys.itemGroupKey
  }

  private func cache<Entity>(
    forId id: Identifier, revision: SharingRevision,
    _ computation: () throws -> SharingSymmetricKey<Entity>?
  ) throws -> SharingSymmetricKey<Entity>? {
    if let cache = groupKeysCache[id], cache.revision == revision {
      return .init(raw: cache.key)
    } else {
      guard let key = try computation()?.raw else {
        return nil
      }

      groupKeysCache[id] = Cache(key: key, revision: revision)
      return .init(raw: key)
    }

  }
}
