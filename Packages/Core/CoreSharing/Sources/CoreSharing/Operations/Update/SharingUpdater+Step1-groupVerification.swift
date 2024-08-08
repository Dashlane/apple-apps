import CyrilKit
import DashTypes
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
        logger.fatal("UserGroup \(group.id) is not valid: \(error)")
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

    let proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
    try group.users.filter { $0.rsaStatus == .sharingKeys }.verifyProposeSignatures(
      using: proposeSignatureProducer)
    _ = try group.info.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
  }

  @discardableResult
  func verifyAndSave(
    _ collections: [SharingCollection]
  ) throws -> (
    savedCollections: [SharingCollection], invalidProposeSignatureCollections: [SharingCollection]
  ) {
    logger.debug("Verify Collections")

    var invalidProposeSignatureCollections: [SharingCollection] = []

    let collections = collections.filter { collection in
      do {
        try verify(collection)
        return true
      } catch SharingGroupError.invalidSignature(.propose, reason: .notValid) {
        invalidProposeSignatureCollections.append(collection)
        logger.fatal(
          "Collection \(collection.id) is not valid: \(SharingGroupError.invalidSignature(.propose, reason: .notValid))"
        )
        return false
      } catch {
        logger.fatal("Collection \(collection.id) is not valid: \(error)")
        return false
      }
    }

    if !collections.isEmpty {
      try database.save(collections)
      logger.debug("\(collections.count) Collection(s) inserted or updated")
    } else {
      logger.debug("No Collection inserted or updated")
    }

    return (
      savedCollections: collections,
      invalidProposeSignatureCollections: invalidProposeSignatureCollections
    )
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

    let proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
    try collection.users.filter { $0.rsaStatus == .sharingKeys }.verifyProposeSignatures(
      using: proposeSignatureProducer)
    try collection.userGroupMembers.verifyProposeSignatures(using: proposeSignatureProducer)
    _ = try collection.info.privateKey(using: groupKey, cryptoProvider: cryptoProvider)
  }

  @discardableResult
  func verifyAndSave(_ groups: [ItemGroup]) throws -> (
    savedGroups: [ItemGroup], invalidProposeSignatureGroups: [ItemGroup]
  ) {
    logger.debug("Verify Item Groups")

    var invalidProposeSignatureGroups: [ItemGroup] = []

    let groups = groups.filter { group in
      do {
        try verify(group)
        return true
      } catch SharingGroupError.invalidSignature(.propose, reason: .notValid) {
        invalidProposeSignatureGroups.append(group)
        logger.fatal(
          "ItemGroup \(group.id) is not valid: \(SharingGroupError.invalidSignature(.propose, reason: .notValid))"
        )

        return false
      } catch {
        logger.fatal("ItemGroup \(group.id) is not valid: \(error)")
        return false
      }
    }

    if !groups.isEmpty {
      try database.save(groups)
      logger.debug("\(groups.count) ItemGroup(s) inserted or updated")
    } else {
      logger.debug("No ItemGroup inserted or updated")
    }

    return (savedGroups: groups, invalidProposeSignatureGroups: invalidProposeSignatureGroups)
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

    let proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
    try group.users.filter { $0.rsaStatus == .sharingKeys }.verifyProposeSignatures(
      using: proposeSignatureProducer)
    try group.userGroupMembers.verifyProposeSignatures(using: proposeSignatureProducer)
    try group.collectionMembers.verifyProposeSignatures(using: proposeSignatureProducer)

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
