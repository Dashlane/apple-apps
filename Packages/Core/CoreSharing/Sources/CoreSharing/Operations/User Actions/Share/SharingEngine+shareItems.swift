import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation

extension SharingEngine {

  @SharingActor
  public func shareItems(
    withIds ids: [Identifier],
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    limitPerUser: Int?,
    userAuditLogDetails: [Identifier: AuditLogDetails]
  ) async throws {
    try await execute { updateRequest in

      let recipients = recipients.map { $0.sanitizedRecipients() }

      let existingItemGroups = try operationDatabase.fetchItemGroups(withItemIds: ids)
      var ids = Set(ids)
      let userPublicKeys = try await sharingClientAPI.findPublicKeys(for: recipients)

      if let limitPerUser = limitPerUser {
        try checkLimitPerUser(
          limitPerUser,
          forRecipients: recipients,
          existingItemGroupIds: existingItemGroups.map(\.id),
          totalNumberOfSharedItems: ids.count)
      }

      for group in existingItemGroups {
        let itemIds = group.itemKeyPairs.map(\.id)
        let auditLogDetails: AuditLogDetails? = itemIds.first.flatMap { userAuditLogDetails[$0] }
        ids.subtract(itemIds)
        try await add(
          into: group,
          recipients: recipients,
          userGroupIds: userGroupIds,
          permission: permission,
          userPublicKeys: userPublicKeys,
          userAuditLogDetails: auditLogDetails,
          updateRequest: &updateRequest)
      }

      let contents = try await personalDataDB.createSharingContents(for: Array(ids))
      for content in contents {
        let auditLogDetails = userAuditLogDetails[content.id]
        try await createSharing(
          for: content,
          recipients: recipients,
          userGroupIds: userGroupIds,
          permission: permission,
          userPublicKeys: userPublicKeys,
          userAuditLogDetails: auditLogDetails,
          updateRequest: &updateRequest)
      }
    }
  }

  func checkLimitPerUser(
    _ limitPerUser: Int,
    forRecipients recipients: [String],
    existingItemGroupIds: [Identifier],
    totalNumberOfSharedItems: Int
  ) throws {
    let counts =
      try operationDatabase
      .sharingCounts(forUserIds: recipients, excludingGroupIds: existingItemGroupIds)
    if counts.values.contains(where: { $0 + totalNumberOfSharedItems > limitPerUser }) {
      throw SharingUpdaterError.sharingLimitReached
    }
  }
}

extension SharingEngine {
  @SharingActor
  private func makeInviteBuilder(
    groupId: Identifier,
    groupKey: SharingSymmetricKey<ItemGroup>,
    permission: SharingPermission,
    userPublicKeys: [UserId: RawPublicKey]
  ) -> InviteBuilder<ItemGroup> {
    InviteBuilder(
      groupId: groupId,
      permission: permission,
      groupKey: groupKey,
      cryptoProvider: cryptoProvider,
      groupKeyProvider: groupKeyProvider,
      database: operationDatabase,
      userPublicKeys: userPublicKeys)
  }

  @SharingActor
  private func createSharing(
    for content: SharingCreateContent,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    userPublicKeys: [String: RawPublicKey],
    userAuditLogDetails: AuditLogDetails?,
    updateRequest: inout SharingUpdater.UpdateRequest
  ) async throws {
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
      encryptedKey: encryptedItemKey)

    let inviteBuilder = makeInviteBuilder(
      groupId: groupId, groupKey: groupKey, permission: permission, userPublicKeys: userPublicKeys)

    let author: UserUpload = try inviteBuilder.makeAuthorUpload(
      userId: userId, userKeyPair: try userKeyStore.get())
    let users = try inviteBuilder.makeUserUploads(recipients: recipients)
    let userGroupInvites: [UserGroupInvite] = try inviteBuilder.makeUserGroupInvites(
      userGroupIds: userGroupIds)

    var updateRequestFromCreation = try await sharingClientAPI.createItemGroup(
      withId: groupId,
      items: [itemUpload],
      users: [author] + users,
      userGroups: userGroupInvites,
      emailsInfo: [EmailInfo(content.metadata)],
      userAuditLogDetails: userAuditLogDetails)

    try operationDatabase.save(updateRequestFromCreation.items)
    updateRequestFromCreation.items = []

    updateRequest += updateRequestFromCreation
  }

  @SharingActor
  private func add(
    into group: ItemGroup,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    userPublicKeys: [UserId: RawPublicKey],
    userAuditLogDetails: AuditLogDetails?,
    updateRequest: inout SharingUpdater.UpdateRequest
  ) async throws {
    guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
      return
    }

    let inviteBuilder = makeInviteBuilder(
      groupId: group.id, groupKey: groupKey, permission: permission, userPublicKeys: userPublicKeys)

    let existingUserIds = Set(group.users.map(\.id))
    let existingUserGroupId = Set(group.userGroupMembers.map(\.id))

    let users: [UserInvite] = try inviteBuilder.makeUserInvites(recipients: recipients)
      .filter { !existingUserIds.contains($0.userId) }

    let userGroupIds = Set(userGroupIds).subtracting(existingUserGroupId)
    let userGroupInvites: [UserGroupInvite] = try inviteBuilder.makeUserGroupInvites(
      userGroupIds: Array(userGroupIds))

    guard !users.isEmpty || !userGroupInvites.isEmpty else {
      return
    }

    let emailInfos = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(
      EmailInfo.init)

    updateRequest += try await sharingClientAPI.inviteOnItemGroup(
      withId: group.id,
      users: users,
      userGroups: userGroupInvites,
      emailsInfo: emailInfos,
      userAuditLogDetails: userAuditLogDetails,
      revision: group.info.revision)
  }
}

extension ItemUpload {
  init(id: Identifier, encryptedContent: String, type: SharingType, encryptedKey: String) {
    self.init(
      itemId: id.rawValue,
      itemKey: encryptedKey,
      content: encryptedContent,
      itemType: ItemType(type))
  }
}

extension ItemUpload.ItemType {
  public init(_ type: SharingType) {
    switch type {
    case .password:
      self = .authentifiant
    case .note:
      self = .securenote
    case .secret:
      self = .secret
    }
  }
}

extension String {
  func sanitizedRecipients() -> String {
    self.lowercased()
      .trimmingCharacters(in: CharacterSet.whitespaces)
  }
}
