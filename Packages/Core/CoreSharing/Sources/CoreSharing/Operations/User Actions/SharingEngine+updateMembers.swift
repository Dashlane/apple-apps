import DashTypes
import DashlaneAPI
import Foundation

extension SharingEngine {
  public func revoke(
    in group: ItemGroupInfo, users: [User<ItemGroup>]?,
    userGroupMembers: [UserGroupMember<ItemGroup>]?, userAuditLogDetails: AuditLogDetails?
  ) async throws {
    try await execute { updateRequest in
      guard let group = try operationDatabase.fetchItemGroup(withId: group.id),
        users?.isEmpty == false || userGroupMembers?.isEmpty == false
      else {
        return
      }

      updateRequest += try await sharingClientAPI.revokeOnItemGroup(
        withId: group.id,
        userIds: users?.map(\.id),
        userGroupIds: userGroupMembers?.map(\.id),
        userAuditLogDetails: userAuditLogDetails,
        origin: .manual,
        revision: group.info.revision)
    }
  }

  public func revoke(
    in collection: CollectionInfo,
    users: [User<SharingCollection>]?,
    userGroupMembers: [UserGroupMember<SharingCollection>]?,
    userAuditLogDetails: AuditLogDetails?
  ) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collection.id),
        users?.isEmpty == false || userGroupMembers?.isEmpty == false
      else {
        return
      }

      updateRequest += try await sharingClientAPI.revokeOnCollection(
        withId: collection.id,
        userIds: users?.map(\.id),
        userGroupIds: userGroupMembers?.map(\.id),
        userAuditLogDetails: userAuditLogDetails,
        revision: collection.info.revision
      )
    }
  }
}

extension SharingEngine {
  public func updatePermission(
    _ permission: SharingPermission, of user: User<ItemGroup>, in group: ItemGroupInfo,
    userAuditLogDetails: AuditLogDetails?
  ) async throws {
    try await execute { updateRequest in
      guard let group = try operationDatabase.fetchItemGroup(withId: group.id) else {
        return
      }

      let update = UserUpdate(
        userId: user.id,
        groupKey: nil,
        permission: .init(permission),
        proposeSignature: nil)
      updateRequest += try await sharingClientAPI.updateOnItemGroup(
        withId: group.id,
        users: [update],
        userGroups: nil,
        userAuditLogDetails: userAuditLogDetails,
        revision: group.info.revision)
    }
  }

  public func updatePermission(
    _ permission: SharingPermission, of userGroupMember: UserGroupMember<ItemGroup>,
    in group: ItemGroupInfo, userAuditLogDetails: AuditLogDetails?
  ) async throws {
    try await execute { updateRequest in
      guard let group = try operationDatabase.fetchItemGroup(withId: group.id) else {
        return
      }

      let update = UserGroupUpdate(
        groupId: userGroupMember.id.rawValue, permission: .init(permission))
      updateRequest += try await sharingClientAPI.updateOnItemGroup(
        withId: group.id,
        users: nil,
        userGroups: [update],
        userAuditLogDetails: userAuditLogDetails,
        revision: group.info.revision)
    }

  }

  public func updatePermission(
    _ permission: SharingPermission,
    of user: User<SharingCollection>,
    in collection: CollectionInfo
  ) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collection.id) else {
        return
      }

      let update = UserCollectionUpdate(
        login: user.id,
        collectionKey: nil,
        permission: .init(permission),
        proposeSignature: nil
      )
      updateRequest += try await sharingClientAPI.updateOnCollection(
        withId: collection.id,
        users: [update],
        userGroups: nil,
        revision: collection.info.revision
      )
    }
  }

  public func updatePermission(
    _ permission: SharingPermission,
    of userGroupMember: UserGroupMember<SharingCollection>,
    in collection: CollectionInfo
  ) async throws {
    try await execute { updateRequest in
      guard let collection = try operationDatabase.fetchCollection(withId: collection.id) else {
        return
      }

      let update = UserGroupCollectionUpdate(
        groupUUID: userGroupMember.id.rawValue,
        permission: .init(permission)
      )

      updateRequest += try await sharingClientAPI.updateOnCollection(
        withId: collection.id,
        users: nil,
        userGroups: [update],
        revision: collection.info.revision
      )
    }
  }
}

extension SharingEngine {
  public func resendInvites(to users: [User<ItemGroup>], in group: ItemGroupInfo) async throws {
    try await execute { _ in
      guard let group = try operationDatabase.fetchItemGroup(withId: group.id) else {
        return
      }

      let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(
        EmailInfo.init)

      try await sharingClientAPI.resendInvite(
        to: users.map { UserInviteResend(userId: $0.id, alias: $0.id) },
        forGroupId: group.id,
        emailsInfo: emailsInfo,
        revision: group.info.revision)
    }
  }
}
