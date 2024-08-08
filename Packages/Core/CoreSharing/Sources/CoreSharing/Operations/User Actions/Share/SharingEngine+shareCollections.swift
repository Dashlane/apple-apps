import CyrilKit
import DashTypes
import DashlaneAPI
import Foundation

private struct ItemGroupCreation {
  let itemGroup:
    UserDeviceAPIClient.SharingUserdevice.CreateMultipleItemGroups.Body.ItemgroupsElement
  let groupId: Identifier
  let groupKey: SharingSymmetricKey<ItemGroup>
}

extension SharingEngine {
  @SharingActor
  public func shareCollections(
    withIdNamePairs idNamePairs: [(id: Identifier, name: String)],
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission
  ) async throws {
    try await execute { updateRequest in
      let recipients = recipients.map { $0.sanitizedRecipients() }

      let existingCollections = try operationDatabase.fetchCollections(
        withIds: idNamePairs.map(\.id))
      var ids = Set(idNamePairs.map(\.id))
      let userPublicKeys = try await sharingClientAPI.findPublicKeys(for: recipients)

      for collection in existingCollections {
        ids.remove(collection.id)
        try await add(
          into: collection,
          recipients: recipients,
          userGroupIds: userGroupIds,
          permission: permission,
          userPublicKeys: userPublicKeys,
          updateRequest: &updateRequest
        )
      }

      let nonExistingCollections = idNamePairs.filter { ids.contains($0.id) }
      for nonExistingCollection in nonExistingCollections {
        try await createSharing(
          for: nonExistingCollection,
          teamId: teamId,
          recipients: recipients,
          userGroupIds: userGroupIds,
          permission: permission,
          userPublicKeys: userPublicKeys,
          updateRequest: &updateRequest
        )
      }
    }
  }

  @SharingActor
  public func addItemsToCollection(
    withId collectionId: Identifier,
    itemIds: [Identifier],
    makeActivityLogDetails: @escaping ([Identifier]) -> [Identifier: AuditLogDetails]
  ) async throws {
    try await execute { updateRequest in
      guard !itemIds.isEmpty else { return }
      guard let collection = try operationDatabase.fetchCollection(withId: collectionId),
        let collectionPrivateKey = try groupKeyProvider.privateKey(for: collection)
      else {
        logger.fatal("Attempted to add items to a collection that is not shared yet")
        return
      }

      let collectionKeys = (
        publicKey: try collection.publicKey(using: cryptoProvider), privateKey: collectionPrivateKey
      )

      let auditLogDetails = makeActivityLogDetails(itemIds)
      let existingItemGroups = try operationDatabase.fetchItemGroups(withItemIds: itemIds)

      var itemIds = Set(itemIds)
      existingItemGroups.forEach { itemIds.subtract($0.itemKeyPairs.map(\.id)) }

      let contents = try await personalDataDB.createSharingContents(for: Array(itemIds))
      let newItemGroups = try await createSharing(
        for: contents,
        updateRequest: &updateRequest
      )

      let inviteBuilder = try makeAddItemsBuilder(
        collectionId: collectionId, collectionKeys: collectionKeys)
      let existingItemGroupIdKeyPairs: [(Identifier, SharingSymmetricKey<ItemGroup>)] =
        try existingItemGroups.compactMap {
          guard let groupKey = try groupKeyProvider.groupKey(for: $0) else { return nil }
          return ($0.id, groupKey)
        }
      let newItemGroupIdKeyPairs = newItemGroups.map { ($0.groupId, $0.groupKey) }
      let itemGroupIdKeyPairs = existingItemGroupIdKeyPairs + newItemGroupIdKeyPairs

      var itemGroupAuditLogs: [Identifier: AuditLogDetails] = [:]
      for itemGroup in existingItemGroups {
        itemGroupAuditLogs[itemGroup.id] =
          auditLogDetails.first(where: { auditLogDetail in
            itemGroup.itemKeyPairs.contains(where: { itemKeyPair in
              auditLogDetail.key == itemKeyPair.id
            })
          })?.value
      }
      for newItemGroup in newItemGroups {
        itemGroupAuditLogs[newItemGroup.groupId] =
          auditLogDetails.first(where: { auditLogDetail in
            newItemGroup.itemGroup.items.contains(where: { item in
              auditLogDetail.key.rawValue == item.itemId
            })
          })?.value
      }

      let itemGroupsToUpload = try inviteBuilder.makeItemGroups(
        itemGroupIdKeyPairs: itemGroupIdKeyPairs, auditLogDetails: itemGroupAuditLogs)

      guard !itemGroupsToUpload.isEmpty else {
        return
      }

      updateRequest += try await sharingClientAPI.addItemGroupsInCollection(
        withId: collection.id,
        itemGroups: itemGroupsToUpload,
        revision: collection.info.revision
      )
    }
  }

  @SharingActor
  private func createSharing(
    for contents: [SharingCreateContent],
    updateRequest: inout SharingUpdater.UpdateRequest
  ) async throws -> [ItemGroupCreation] {
    guard !contents.isEmpty else { return [] }

    let itemGroups = try contents.map { try makeItemGroupCreation(content: $0) }

    var updateRequestFromCreation = try await sharingClientAPI.createItemGroups(
      itemGroups.map(\.itemGroup))

    try operationDatabase.save(updateRequestFromCreation.items)
    updateRequestFromCreation.items = []

    return itemGroups
  }

  @SharingActor
  private func makeItemGroupCreation(
    content: SharingCreateContent
  ) throws -> ItemGroupCreation {
    let groupKey = SharingSymmetricKey<ItemGroup>(raw: cryptoProvider.makeSymmetricKey())
    let itemKey = SharingSymmetricKey<ItemKeyPair>(raw: cryptoProvider.makeSymmetricKey())
    let groupId = Identifier()
    let encryptedItemKey = try itemKey.encrypt(groupKey, cryptoProvider: cryptoProvider)
    let encryptedContent = try content.encryptedContent(
      using: itemKey, cryptoProvider: cryptoProvider)

    let itemUpload = ItemUpload(
      id: content.id,
      encryptedContent: encryptedContent,
      type: content.metadata.type,
      encryptedKey: encryptedItemKey
    )

    let inviteBuilder = makeInviteBuilder(groupId: groupId, groupKey: groupKey, permission: .admin)
    let author: UserUpload = try inviteBuilder.makeAuthorUpload(
      userId: userId, userKeyPair: try userKeyStore.get())

    return .init(
      itemGroup: .init(
        groupId: groupId.rawValue,
        users: [author],
        items: [itemUpload],
        itemsForEmailing: [.init(content.metadata)]
      ),
      groupId: groupId,
      groupKey: groupKey
    )
  }

  @SharingActor
  public func removeItemsFromCollection(
    withId collectionId: Identifier,
    itemIds: [Identifier],
    makeActivityLogDetails: @escaping ([Identifier]) -> [Identifier: AuditLogDetails]
  ) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collectionId) else {
        logger.fatal("Attempted to remove shared items from a collection that is not shared")
        return
      }

      let itemGroups = try operationDatabase.fetchItemGroups(withItemIds: itemIds)

      guard !itemGroups.isEmpty else {
        return
      }

      var itemGroupAuditLogs:
        [UserDeviceAPIClient.SharingUserdevice.RemoveItemGroupsFromCollection.Body
          .ItemGroupAuditLogsElement] = []
      for itemGroup in itemGroups {
        guard
          let activityLogDetails = makeActivityLogDetails(itemGroup.itemKeyPairs.map(\.id)).map(
            \.value
          ).first
        else {
          continue
        }
        itemGroupAuditLogs.append(
          .init(uuid: itemGroup.id.rawValue, auditLogDetails: activityLogDetails))
      }

      updateRequest += try await sharingClientAPI.removeItemGroupsFromCollection(
        withId: collection.id,
        itemGroupIds: itemGroups.map(\.id),
        revision: collection.info.revision,
        itemGroupAuditLogs: itemGroupAuditLogs.isEmpty ? nil : itemGroupAuditLogs
      )
    }
  }

  @SharingActor
  public func renameCollection(
    withId collectionId: Identifier,
    name: String
  ) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collectionId) else {
        logger.fatal("Attempted to rename a collection that is not shared")
        return
      }

      updateRequest += try await sharingClientAPI.renameCollection(
        withId: collectionId,
        name: name,
        revision: collection.info.revision
      )
    }
  }

  @SharingActor
  public func deleteCollection(withId collectionId: Identifier) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collectionId) else {
        logger.fatal("Attempted to delete a collection that is not shared")
        return
      }

      updateRequest += try await sharingClientAPI.deleteCollection(
        withId: collectionId,
        revision: collection.info.revision
      )
    }
  }
}

extension SharingEngine {
  @SharingActor
  fileprivate func makeInviteBuilder(
    collectionId: Identifier,
    collectionKey: SharingSymmetricKey<SharingCollection>,
    permission: SharingPermission,
    userPublicKeys: [UserId: RawPublicKey]
  ) -> InviteBuilder<SharingCollection> {
    InviteBuilder(
      groupId: collectionId,
      permission: permission,
      groupKey: collectionKey,
      cryptoProvider: cryptoProvider,
      groupKeyProvider: groupKeyProvider,
      database: operationDatabase,
      userPublicKeys: userPublicKeys
    )
  }

  @SharingActor
  fileprivate func makeInviteBuilder(
    groupId: Identifier,
    groupKey: SharingSymmetricKey<ItemGroup>,
    permission: SharingPermission
  ) -> InviteBuilder<ItemGroup> {
    InviteBuilder(
      groupId: groupId,
      permission: permission,
      groupKey: groupKey,
      cryptoProvider: cryptoProvider,
      groupKeyProvider: groupKeyProvider,
      database: operationDatabase,
      userPublicKeys: [:]
    )
  }

  @SharingActor
  fileprivate func makeAddItemsBuilder(
    collectionId: Identifier,
    collectionKeys: (
      publicKey: SharingPublicKey<SharingCollection>,
      privateKey: SharingPrivateKey<SharingCollection>
    )
  ) throws -> InviteItemGroupInCollectionBuilder {
    InviteItemGroupInCollectionBuilder(
      cryptoProvider: cryptoProvider,
      collectionId: collectionId,
      collectionKeys: collectionKeys
    )
  }

  @SharingActor
  fileprivate func createSharing(
    for collection: (id: Identifier, name: String),
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    userPublicKeys: [String: RawPublicKey],
    updateRequest: inout SharingUpdater.UpdateRequest
  ) async throws {
    let groupKey = SharingSymmetricKey<SharingCollection>(raw: cryptoProvider.makeSymmetricKey())
    let asymmetricKeyPair = try cryptoProvider.makeAsymmetricKey()
    let pemPublicKey = try cryptoProvider.pemString(for: asymmetricKeyPair.publicKey)
    let privateKey = SharingPrivateKey<SharingCollection>(raw: asymmetricKeyPair.privateKey)
    let encryptedPrivateKey = try SharingCollection.encrypt(
      privateKey, with: groupKey, cryptoProvider: cryptoProvider)

    let collection = SharingCollection(
      id: collection.id,
      name: collection.name,
      publicKey: pemPublicKey,
      encryptedPrivateKey: encryptedPrivateKey
    )

    let inviteBuilder = makeInviteBuilder(
      collectionId: collection.id,
      collectionKey: groupKey,
      permission: permission,
      userPublicKeys: userPublicKeys
    )

    let author: UserCollectionUpload = try inviteBuilder.makeAuthorUpload(
      userId: userId, userKeyPair: try userKeyStore.get())
    let users = try inviteBuilder.makeUserUploads(recipients: recipients)
    let userGroupInvites: [UserGroupCollectionInvite] = try inviteBuilder.makeUserGroupInvites(
      userGroupIds: userGroupIds)

    updateRequest += try await sharingClientAPI.createCollection(
      collection,
      teamId: teamId,
      users: [author] + users,
      userGroups: userGroupInvites
    )
  }

  @SharingActor
  fileprivate func add(
    into collection: SharingCollection,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    userPublicKeys: [UserId: RawPublicKey],
    updateRequest: inout SharingUpdater.UpdateRequest
  ) async throws {
    guard let groupKey = try groupKeyProvider.groupKey(for: collection) else {
      return
    }

    let inviteBuilder = makeInviteBuilder(
      collectionId: collection.id,
      collectionKey: groupKey,
      permission: permission,
      userPublicKeys: userPublicKeys
    )

    let existingUserIds = Set(collection.users.map(\.id))
    let existingUserGroupId = Set(collection.userGroupMembers.map(\.id))

    let users: [UserCollectionUpload] = try inviteBuilder.makeUserInvites(recipients: recipients)
      .filter { !existingUserIds.contains($0.login) }

    let userGroupIds = Set(userGroupIds).subtracting(existingUserGroupId)
    let userGroupInvites: [UserGroupCollectionInvite] = try inviteBuilder.makeUserGroupInvites(
      userGroupIds: Array(userGroupIds))

    guard !users.isEmpty || !userGroupInvites.isEmpty else {
      return
    }

    updateRequest += try await sharingClientAPI.inviteOnCollection(
      withId: collection.id,
      users: users,
      userGroups: userGroupInvites,
      revision: collection.info.revision
    )
  }
}

extension SharingCollection {
  fileprivate init(id: Identifier, name: String, publicKey: String, encryptedPrivateKey: String) {
    self.init(
      info: .init(
        id: id,
        name: name,
        publicKey: publicKey,
        encryptedPrivateKey: encryptedPrivateKey,
        revision: 1),
      users: [],
      userGroupMembers: [])
  }
}
