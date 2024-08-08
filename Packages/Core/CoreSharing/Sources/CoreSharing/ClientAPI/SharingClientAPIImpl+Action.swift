import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

extension SharingClientAPIImpl {
  fileprivate func catchInvalid<Response>(
    forId id: Identifier, _ action: () async throws -> Response
  ) async throws -> Response {
    do {
      return try await action()
    } catch let error as DashlaneAPI.APIError
      where error.hasSharingUserdeviceCode(.invalidItemGroupRevision)
    {
      throw SharingInvalidActionError(id: id, type: .itemGroup)
    } catch let error as DashlaneAPI.APIError
      where error.hasSharingUserdeviceCode(.invalidItemTimestamp)
    {
      throw SharingInvalidActionError(id: id, type: .item)
    } catch let error as DashlaneAPI.APIError
      where error.hasSharingUserdeviceCode(.invalidUserGroupRevision)
    {
      throw SharingInvalidActionError(id: id, type: .userGroup)
    } catch let error as DashlaneAPI.APIError
      where error.hasSharingUserdeviceCode(.invalidCollectionRevision)
    {
      throw SharingInvalidActionError(id: id, type: .collection)
    }
  }
}

extension SharingClientAPIImpl {
  public func acceptItemGroup(
    withId groupId: Identifier,
    userGroupId: Identifier?,
    acceptSignature: String,
    autoAccept: Bool?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.acceptItemGroup(
        revision: revision,
        groupId: groupId.rawValue,
        acceptSignature: acceptSignature,
        auditLogDetails: userAuditLogDetails,
        autoAccept: autoAccept,
        itemsForEmailing: emailsInfo,
        userGroupId: userGroupId?.rawValue)
    }.parsed()
  }

  public func refuseItemGroup(
    withId groupId: Identifier,
    userGroupId: Identifier?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.refuseItemGroup(
        revision: revision,
        groupId: groupId.rawValue,
        auditLogDetails: userAuditLogDetails,
        itemsForEmailing: emailsInfo,
        userGroupId: userGroupId?.rawValue)
    }.parsed()
  }

  public func createItemGroup(
    withId groupId: Identifier,
    items: [ItemUpload],
    users: [UserUpload],
    @NilIfEmpty userGroups: [UserGroupInvite]?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.createItemGroup(
        groupId: groupId.rawValue,
        users: users,
        items: items,
        auditLogDetails: userAuditLogDetails,
        groups: userGroups,
        itemsForEmailing: emailsInfo)
    }.parsed()
  }

  public func createItemGroups(
    _ itemGroups: [UserDeviceAPIClient.SharingUserdevice.CreateMultipleItemGroups.Body
      .ItemgroupsElement]
  ) async throws -> ParsedServerResponse {
    try await apiClient.createMultipleItemGroups(itemgroups: itemGroups).parsed()
  }

  public func deleteItemGroup(withId groupId: Identifier, revision: SharingRevision) async throws
    -> ParsedServerResponse
  {
    try await catchInvalid(forId: groupId) {
      try await apiClient.deleteItemGroup(groupId: groupId.rawValue, revision: revision)
    }.parsed()
  }

  public func updateOnItemGroup(
    withId groupId: Identifier,
    @NilIfEmpty users: [UserUpdate]?,
    @NilIfEmpty userGroups: [UserGroupUpdate]?,
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.updateItemGroupMembers(
        revision: revision,
        groupId: groupId.rawValue,
        groups: userGroups,
        users: users)
    }.parsed()
  }

  public func inviteOnItemGroup(
    withId groupId: Identifier,
    users: [UserInvite]?,
    @NilIfEmpty userGroups: [UserGroupInvite]?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.inviteItemGroupMembers(
        revision: revision,
        groupId: groupId.rawValue,
        auditLogDetails: userAuditLogDetails,
        groups: userGroups,
        itemsForEmailing: emailsInfo,
        users: users)
    }.parsed()
  }

  public func revokeOnItemGroup(
    withId groupId: Identifier,
    @NilIfEmpty userIds: [UserId]?,
    @NilIfEmpty userGroupIds: [Identifier]?,
    userAuditLogDetails: AuditLogDetails?,
    origin: UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers.Body.Origin,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.revokeItemGroupMembers(
        revision: revision,
        groupId: groupId.rawValue,
        auditLogDetails: userAuditLogDetails,
        groups: userGroupIds?.map(\.rawValue),
        origin: origin,
        users: userIds)
    }.parsed()
  }
}

extension SharingClientAPIImpl {
  public func updateItem(
    with itemId: Identifier, encryptedContent: String, timestamp: SharingTimestamp
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: itemId) {
      try await apiClient.updateItem(
        itemId: itemId.rawValue,
        content: encryptedContent,
        timestamp: timestamp)
    }.parsed()
  }
}

extension SharingClientAPIImpl {
  public func acceptCollection(
    withId collectionId: Identifier,
    userGroupId: Identifier?,
    acceptSignature: String,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.acceptCollection(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        acceptSignature: acceptSignature,
        userGroupUUID: userGroupId?.rawValue
      )
    }.parsed()
  }

  public func refuseCollection(
    withId collectionId: Identifier,
    userGroupId: Identifier?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.refuseCollection(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        userGroupUUID: userGroupId?.rawValue
      )
    }.parsed()
  }

  public func createCollection(
    _ collection: SharingCollection,
    teamId: Int?,
    users: [UserCollectionUpload],
    @NilIfEmpty userGroups: [UserGroupCollectionInvite]?
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collection.id) {
      try await apiClient.createCollection(
        collectionUUID: collection.id.rawValue,
        collectionName: collection.info.name,
        users: users,
        publicKey: collection.info.publicKey,
        privateKey: collection.info.encryptedPrivateKey,
        teamId: teamId,
        userGroups: userGroups
      )
    }.parsed()
  }

  public func deleteCollection(
    withId collectionId: Identifier,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.deleteCollection(
        collectionUUID: collectionId.rawValue,
        revision: revision
      )
    }.parsed()
  }

  public func renameCollection(
    withId collectionId: Identifier,
    name: String,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.renameCollection(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        updatedName: name
      )
    }.parsed()
  }

  public func updateOnCollection(
    withId collectionId: Identifier,
    @NilIfEmpty users: [UserCollectionUpdate]?,
    @NilIfEmpty userGroups: [UserGroupCollectionUpdate]?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.updateCollectionMembers(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        userGroups: userGroups,
        users: users
      )
    }.parsed()
  }

  public func inviteOnCollection(
    withId collectionId: Identifier,
    @NilIfEmpty users: [UserCollectionUpload]?,
    @NilIfEmpty userGroups: [UserGroupCollectionInvite]?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.inviteCollectionMembers(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        userGroups: userGroups,
        users: users
      )
    }.parsed()
  }

  public func revokeOnCollection(
    withId collectionId: Identifier,
    @NilIfEmpty userIds: [UserId]?,
    @NilIfEmpty userGroupIds: [Identifier]?,
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.revokeCollectionMembers(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        userGroupUUIDs: userGroupIds?.map(\.rawValue),
        userLogins: userIds
      )
    }.parsed()
  }

  public func addItemGroupsInCollection(
    withId collectionId: Identifier,
    itemGroups: [UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection.Body
      .ItemGroupsElement],
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.addItemGroupsToCollection(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        itemGroups: itemGroups
      )
    }.parsed()
  }

  public func removeItemGroupsFromCollection(
    withId collectionId: Identifier,
    itemGroupIds: [Identifier],
    revision: SharingRevision,
    @NilIfEmpty itemGroupAuditLogs: [UserDeviceAPIClient.SharingUserdevice
      .RemoveItemGroupsFromCollection.Body.ItemGroupAuditLogsElement]?
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: collectionId) {
      try await apiClient.removeItemGroupsFromCollection(
        revision: revision,
        collectionUUID: collectionId.rawValue,
        itemGroupUUIDs: itemGroupIds.map(\.rawValue),
        itemGroupAuditLogs: itemGroupAuditLogs
      )
    }.parsed()
  }
}

extension SharingClientAPIImpl {
  public func acceptUserGroup(
    withId groupId: Identifier,
    acceptSignature: String,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.acceptUserGroup(
        provisioningMethod: .user,
        revision: revision,
        groupId: groupId.rawValue,
        acceptSignature: acceptSignature)
    }.parsed()
  }

  public func refuseUserGroup(withId groupId: Identifier, revision: SharingRevision) async throws
    -> ParsedServerResponse
  {
    try await catchInvalid(forId: groupId) {
      try await apiClient.refuseUserGroup(
        provisioningMethod: .user,
        revision: revision,
        groupId: groupId.rawValue)
    }.parsed()
  }

  public func updateOnUserGroup(
    withId groupId: Identifier,
    users: [UserUpdate],
    revision: SharingRevision
  ) async throws -> ParsedServerResponse {
    try await catchInvalid(forId: groupId) {
      try await apiClient.updateUserGroupUsers(
        revision: revision,
        groupId: groupId.rawValue,
        users: users)
    }.parsed()
  }
}

extension SharingClientAPIImpl {
  public func resendInvite(
    to users: [UserInviteResend],
    forGroupId groupId: Identifier,
    emailsInfo: [EmailInfo],
    revision: SharingRevision
  ) async throws {
    try await catchInvalid(forId: groupId) {
      _ = try await apiClient.resendItemGroupInvites(
        revision: revision,
        groupId: groupId.rawValue,
        users: users,
        itemsForEmailing: emailsInfo)
    }
  }
}
