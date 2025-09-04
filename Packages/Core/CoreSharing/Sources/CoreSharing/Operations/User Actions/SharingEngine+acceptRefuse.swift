import CoreTypes
import DashlaneAPI
import Foundation

extension SharingEngine {
  public func accept(_ itemGroupInfo: ItemGroupInfo, userAuditLogDetails: AuditLogDetails?)
    async throws
  {
    try await execute { updateRequest in
      guard let group = try operationDatabase.fetchItemGroup(withId: itemGroupInfo.id),
        let user = group.user(with: userId),
        user.status == .pending,
        let groupKey = try groupKeyProvider.groupKey(for: group)
      else {
        return
      }

      let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(
        EmailInfo.init)
      let acceptSignature = try user.createAcceptSignature(
        using: userKeyStore.get().privateKey, groupKey: groupKey, cryptoProvider: cryptoProvider)

      updateRequest += try await sharingClientAPI.acceptItemGroup(
        withId: group.id,
        userGroupId: nil,
        acceptSignature: acceptSignature,
        autoAccept: false,
        emailsInfo: emailsInfo,
        userAuditLogDetails: userAuditLogDetails,
        revision: group.info.revision)
    }
  }

  public func refuse(_ itemGroupInfo: ItemGroupInfo, userAuditLogDetails: AuditLogDetails?)
    async throws
  {
    guard let group = try operationDatabase.fetchItemGroup(withId: itemGroupInfo.id) else {
      return
    }

    try await refuse(group, userAuditLogDetails: userAuditLogDetails)
  }

  private func refuse(_ group: ItemGroup, userAuditLogDetails: AuditLogDetails?) async throws {
    try await execute { updateRequest in
      let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(
        EmailInfo.init)

      updateRequest += try await sharingClientAPI.refuseItemGroup(
        withId: group.id,
        userGroupId: nil,
        emailsInfo: emailsInfo,
        userAuditLogDetails: userAuditLogDetails,
        revision: group.info.revision)
    }
  }

  public func refuseItem(with id: Identifier, userAuditLogDetails: AuditLogDetails?) async throws {
    guard let itemGroup = try operationDatabase.fetchItemGroup(withItemId: id) else {
      return
    }

    try await refuse(itemGroup, userAuditLogDetails: userAuditLogDetails)
  }
}

extension SharingEngine {
  public func accept(_ groupInfo: UserGroupInfo) async throws {
    try await execute { updateRequest in
      guard let group = try operationDatabase.fetchUserGroup(withId: groupInfo.id),
        let user = group.user(with: userId),
        user.status == .pending,
        let groupKey = try groupKeyProvider.groupKey(for: group)
      else {
        return
      }

      let acceptSignature = try user.createAcceptSignature(
        using: userKeyStore.get().privateKey, groupKey: groupKey, cryptoProvider: cryptoProvider)

      updateRequest += try await sharingClientAPI.acceptUserGroup(
        withId: group.id,
        acceptSignature: acceptSignature,
        revision: group.info.revision)
    }
  }

  public func refuse(_ groupInfo: UserGroupInfo) async throws {
    try await execute { updateRequest in
      guard let group = try operationDatabase.fetchUserGroup(withId: groupInfo.id) else {
        return
      }

      updateRequest += try await sharingClientAPI.refuseUserGroup(
        withId: group.id, revision: group.info.revision)
    }
  }
}

extension SharingEngine {
  public func accept(_ collectionInfo: CollectionInfo) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collectionInfo.id),
        let user = collection.user(with: userId),
        user.status == .pending,
        let groupKey = try groupKeyProvider.groupKey(for: collection)
      else {
        return
      }

      let acceptSignature = try User<SharingCollection>.createAcceptSignature(
        using: try userKeyStore.get().privateKey,
        groupInfo: (id: collection.id, key: groupKey),
        cryptoProvider: cryptoProvider
      )

      updateRequest += try await sharingClientAPI.acceptCollection(
        withId: collection.id,
        userGroupId: nil,
        acceptSignature: acceptSignature,
        revision: collection.info.revision
      )
    }
  }

  public func refuse(_ collectionInfo: CollectionInfo) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collectionInfo.id) else {
        return
      }

      updateRequest += try await sharingClientAPI.refuseCollection(
        withId: collection.id,
        userGroupId: nil,
        revision: collection.info.revision
      )
    }
  }
}
