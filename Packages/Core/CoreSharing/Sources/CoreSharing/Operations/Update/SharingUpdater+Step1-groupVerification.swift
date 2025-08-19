import CoreTypes
import CyrilKit
import Foundation

extension SharingUpdater {
  @discardableResult
  func verifyAndSave(_ groups: [UserGroup]) throws -> [UserGroup] {
    logger.debug("Verify User Groups")
    let groups = groups.filter { group in
      do {
        try verify(group)
        return true
      } catch {
        logger.fatal("UserGroup \(group.id, privacy: .public) is not valid: \(error)")
        return false
      }
    }

    guard !groups.isEmpty else {
      logger.debug("No UserGroup inserted or updated")
      return []
    }

    try database.save(groups)

    logger.debug("\(groups.count) UserGroup(s) inserted or updated")

    return groups
  }

  private func verify(_ group: UserGroup) throws {
    guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
      return
    }

    if let user = group.user(with: userId) {
      try verifyAcceptSignature(of: user, groupKey: groupKey)
    }

    _ = try group.info.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
  }

  @discardableResult
  func verifyAndSave(_ collections: [SharingCollection]) throws -> [SharingCollection] {
    logger.debug("Verify Collections")

    let collections = collections.filter { collection in
      do {
        try verify(collection)
        return true
      } catch {
        logger.fatal("Collection \(collection.id, privacy: .public) is not valid: \(error)")
        return false
      }
    }

    if !collections.isEmpty {
      try database.save(collections)
      logger.debug("\(collections.count) Collection(s) inserted or updated")
    } else {
      logger.debug("No Collection inserted or updated")
    }

    return collections
  }

  private func verify(_ collection: SharingCollection) throws {
    guard let groupKey = try groupKeyProvider.groupKey(for: collection) else {
      return
    }

    if let user = collection.user(with: userId) {
      try verifyAcceptSignature(of: user, groupKey: groupKey)
    }

    for userGroupMember in collection.userGroupMembers {
      try verifyAcceptSignature(of: userGroupMember, groupKey: groupKey)
    }

    _ = try collection.info.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
  }

  @discardableResult
  func verifyAndSave(_ groups: [ItemGroup]) throws -> [ItemGroup] {
    logger.debug("Verify Item Groups")

    let groups = groups.filter { group in
      do {
        try verify(group)
        return true
      } catch {
        logger.fatal("ItemGroup \(group.id, privacy: .public) is not valid: \(error)")
        return false
      }
    }

    if !groups.isEmpty {
      try database.save(groups)
      logger.debug("\(groups.count) ItemGroup(s) inserted or updated")
    } else {
      logger.debug("No ItemGroup inserted or updated")
    }

    return groups
  }

  private func verify(_ group: ItemGroup) throws {
    guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
      return
    }

    if let user = group.user(with: userId) {
      try verifyAcceptSignature(of: user, groupKey: groupKey)
    }

    for userGroupMember in group.userGroupMembers {
      try verifyAcceptSignature(of: userGroupMember, groupKey: groupKey)
    }

    for collectionMember in group.collectionMembers {
      try verifyAcceptSignature(of: collectionMember, groupKey: groupKey)
    }

    for item in group.itemKeyPairs {
      _ = try item.key(using: groupKey, cryptoProvider: cryptoProvider)
    }
  }

  private func verifyAcceptSignature<Group: SharingGroup>(
    of user: User<Group>, groupKey: SharingSymmetricKey<Group>
  ) throws {
    guard user.status == .accepted else {
      return
    }

    try user.verifyAcceptSignature(
      using: userKeyProvider().publicKey, groupKey: groupKey, cryptoProvider: cryptoProvider)
  }

  private func verifyAcceptSignature<Group: SharingGroup>(
    of userGroupMember: UserGroupMember<Group>, groupKey: SharingSymmetricKey<Group>
  ) throws {
    guard userGroupMember.status == .accepted,
      let pair = try database.fetchUserGroupUserPair(
        withGroupId: userGroupMember.id, userId: userId)
    else {
      return
    }

    let publicKey = try pair.group.publicKey(using: cryptoProvider)
    try userGroupMember.verifyAcceptSignature(
      using: publicKey, groupKey: groupKey, cryptoProvider: cryptoProvider)
  }

  private func verifyAcceptSignature(
    of collectionMember: CollectionMember, groupKey: SharingSymmetricKey<ItemGroup>
  ) throws {
    guard collectionMember.status == .accepted,
      let pair = try database.fetchCollectionUserPair(
        withCollectionId: collectionMember.id, userId: userId)
    else {
      return
    }

    let publicKey = try pair.collection.publicKey(using: cryptoProvider)
    try collectionMember.verifyAcceptSignature(
      using: publicKey, groupKey: groupKey, cryptoProvider: cryptoProvider)
  }
}
