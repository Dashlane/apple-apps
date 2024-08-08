import CyrilKit
import DashTypes
import DashlaneAPI
import Foundation

extension SharingUpdater {
  func autoAcceptUserGroupsAndSendKeyToNewUsers(
    in groups: [ItemGroup], nextRequest: inout UpdateRequest
  ) async throws {
    for group in groups {
      do {
        try await sendGroupKeyAndSignatureForUsersIfNeeded(in: group, nextRequest: &nextRequest)
        try await autoAcceptUserGroupIfNeeded(in: group, nextRequest: &nextRequest)
      } catch let error as SharingInvalidActionError {
        nextRequest += UpdateRequest(error: error)
        logger.error("item group not up to date")
      } catch {
        logger.error("updating item group failed", error: error)
      }
    }
  }

  func autoAcceptUserGroupsAndSendKeyToNewUsers(
    in collections: [SharingCollection],
    nextRequest: inout UpdateRequest
  ) async throws {
    for collection in collections {
      do {
        try await sendGroupKeyAndSignatureForUsersIfNeeded(
          in: collection, nextRequest: &nextRequest)
        try await autoAcceptUserGroupIfNeeded(in: collection, nextRequest: &nextRequest)
      } catch let error as SharingInvalidActionError {
        nextRequest += UpdateRequest(error: error)
        logger.error("item group not up to date")
      } catch {
        logger.error("updating item group failed", error: error)
      }
    }
  }

  func sendKeyToNewUsers(in groups: [UserGroup], nextRequest: inout UpdateRequest) async throws {
    for group in groups {
      do {
        try await sendGroupKeyAndSignatureForUsersIfNeeded(in: group, nextRequest: &nextRequest)
      } catch let error as SharingInvalidActionError {
        nextRequest += UpdateRequest(error: error)
        logger.error("user group not up to date")
      } catch {
        logger.error("updating user group failed", error: error)
      }
    }
  }
}

extension SharingUpdater {
  private func sendGroupKeyAndSignatureForUsersIfNeeded(
    in group: ItemGroup, nextRequest: inout UpdateRequest
  ) async throws {
    let users = group.users.filter { $0.needKeyUpdate }

    guard !users.isEmpty,
      let itemState = try database.sharingMembers(forUserId: userId, in: group).computeItemState(),
      itemState.isAccepted, itemState.permission == .admin,
      let groupKey = try? groupKeyProvider.groupKey(for: group)
    else {
      return
    }

    let userUpdates = try await makeUserUpdates(users: users, groupKey: groupKey)

    nextRequest += try await sharingClientAPI.updateOnItemGroup(
      withId: group.id,
      users: userUpdates,
      userGroups: nil,
      userAuditLogDetails: nil,
      revision: group.info.revision)
  }

  private func sendGroupKeyAndSignatureForUsersIfNeeded(
    in collection: SharingCollection,
    nextRequest: inout UpdateRequest
  ) async throws {
    let users = collection.users.filter { $0.needKeyUpdate }

    guard !users.isEmpty,
      let collectionState = try database.sharingMembers(forUserId: userId, in: collection)
        .computeItemState(),
      collectionState.isAccepted, collectionState.permission == .admin,
      let groupKey = try? groupKeyProvider.groupKey(for: collection)
    else {
      return
    }

    let userUpdates = try await makeUserCollectionUpdates(users: users, collectionKey: groupKey)

    nextRequest += try await sharingClientAPI.updateOnCollection(
      withId: collection.id,
      users: userUpdates,
      userGroups: nil,
      revision: collection.info.revision
    )
  }

  private func sendGroupKeyAndSignatureForUsersIfNeeded(
    in group: UserGroup, nextRequest: inout UpdateRequest
  ) async throws {
    let users = group.users.filter { $0.needKeyUpdate }

    guard !users.isEmpty,
      let currentUser = group.user(with: userId), currentUser.permission == .admin,
      currentUser.status == .accepted,
      let groupKey = try? groupKeyProvider.groupKey(for: group)
    else {
      return
    }

    let userUpdates = try await makeUserUpdates(users: users, groupKey: groupKey)

    nextRequest += try await sharingClientAPI.updateOnUserGroup(
      withId: group.id,
      users: userUpdates,
      revision: group.info.revision)
  }

  private func makeUserUpdates<Group: SharingGroup>(
    users: [User<Group>], groupKey: SharingSymmetricKey<Group>
  ) async throws -> [UserUpdate] {
    let userPublicKeys = try await sharingClientAPI.findPublicKeys(for: users.map(\.id))
    let signatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)

    return try users.compactMap { user -> UserUpdate? in
      guard let publicKeyPEM = userPublicKeys[user.id] else {
        return nil
      }

      let publicKey = try cryptoProvider.userPublicKey(fromPemString: publicKeyPEM)
      let groupKey = try User<Group>.encrypt(
        groupKey, with: publicKey, cryptoProvider: cryptoProvider)
      let signature = try user.createProposeSignature(using: signatureProducer)

      return UserUpdate(
        userId: user.id,
        groupKey: groupKey,
        permission: nil,
        proposeSignature: signature)
    }
  }

  private func makeUserCollectionUpdates(
    users: [User<SharingCollection>],
    collectionKey: SharingSymmetricKey<SharingCollection>
  ) async throws -> [UserCollectionUpdate] {
    let userPublicKeys = try await sharingClientAPI.findPublicKeys(for: users.map(\.id))
    let signatureProducer = cryptoProvider.proposeSignatureProducer(using: collectionKey)

    return try users.compactMap { user -> UserCollectionUpdate? in
      guard let publicKeyPEM = userPublicKeys[user.id] else {
        return nil
      }

      let publicKey = try cryptoProvider.userPublicKey(fromPemString: publicKeyPEM)
      let collectionKey = try User<SharingCollection>.encrypt(
        collectionKey, with: publicKey, cryptoProvider: cryptoProvider)
      let signature = try user.createProposeSignature(using: signatureProducer)

      return UserCollectionUpdate(
        login: user.id,
        collectionKey: collectionKey,
        permission: nil,
        proposeSignature: signature
      )
    }
  }
}

extension SharingUpdater {
  private func autoAcceptUserGroupIfNeeded(in group: ItemGroup, nextRequest: inout UpdateRequest)
    async throws
  {
    guard !group.userGroupMembers.isEmpty,
      let groupKey = try? groupKeyProvider.groupKey(for: group)
    else {
      return
    }

    for userGroupMember in group.userGroupMembers {
      guard userGroupMember.status == .pending,
        let userGroup = try database.fetchUserGroup(withId: userGroupMember.id),
        let currentUser = userGroup.user(with: userId), currentUser.status == .accepted,
        let keys = try groupKeyProvider.keys(for: userGroupMember)
      else {
        continue
      }

      let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(
        EmailInfo.init)
      let acceptSignature = try userGroupMember.createAcceptSignature(
        using: keys.privateKey, groupKey: groupKey, cryptoProvider: cryptoProvider)

      nextRequest += try await sharingClientAPI.acceptItemGroup(
        withId: group.id,
        userGroupId: userGroupMember.id,
        acceptSignature: acceptSignature,
        autoAccept: true,
        emailsInfo: emailsInfo,
        userAuditLogDetails: nil,
        revision: group.info.revision)
    }
  }

  private func autoAcceptUserGroupIfNeeded(
    in collection: SharingCollection,
    nextRequest: inout UpdateRequest
  ) async throws {
    guard !collection.userGroupMembers.isEmpty,
      let groupKey = try? groupKeyProvider.groupKey(for: collection)
    else {
      return
    }

    for userGroupMember in collection.userGroupMembers {
      guard userGroupMember.status == .pending,
        let userGroup = try database.fetchUserGroup(withId: userGroupMember.id),
        let currentUser = userGroup.user(with: userId), currentUser.status == .accepted,
        let keys = try groupKeyProvider.keys(for: userGroupMember)
      else {
        continue
      }

      let acceptSignature = try userGroupMember.createAcceptSignature(
        using: keys.privateKey, groupKey: groupKey, cryptoProvider: cryptoProvider)

      nextRequest += try await sharingClientAPI.acceptCollection(
        withId: collection.id,
        userGroupId: userGroup.id,
        acceptSignature: acceptSignature,
        revision: collection.info.revision
      )
    }
  }
}

extension User {
  fileprivate var needKeyUpdate: Bool {
    return rsaStatus == .publicKey
  }
}
