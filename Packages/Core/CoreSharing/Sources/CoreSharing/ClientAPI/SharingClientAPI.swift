import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats

public protocol SharingClientAPI {
  func fetch(_ request: FetchRequest) async throws -> ParsedServerResponse
  func findPublicKeys(for userIds: [UserId]) async throws -> [UserId: RawPublicKey]
  func getTeamLogins() async throws -> [String]

  func acceptItemGroup(
    withId groupId: Identifier,
    userGroupId: Identifier?,
    acceptSignature: String,
    autoAccept: Bool?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func refuseItemGroup(
    withId groupId: Identifier,
    userGroupId: Identifier?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func createItemGroup(
    withId groupId: Identifier,
    items: [ItemUpload],
    users: [UserUpload],
    userGroups: [UserGroupInvite]?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?
  ) async throws -> ParsedServerResponse

  func createItemGroups(
    _ itemGroups: [UserDeviceAPIClient.SharingUserdevice.CreateMultipleItemGroups.Body
      .ItemgroupsElement]
  ) async throws -> ParsedServerResponse

  func deleteItemGroup(withId groupId: Identifier, revision: Int) async throws
    -> ParsedServerResponse

  func updateOnItemGroup(
    withId groupId: Identifier,
    users: [UserUpdate]?,
    userGroups: [UserGroupUpdate]?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse
  func inviteOnItemGroup(
    withId groupId: Identifier,
    users: [UserInvite]?,
    userGroups: [UserGroupInvite]?,
    emailsInfo: [EmailInfo],
    userAuditLogDetails: AuditLogDetails?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse
  func revokeOnItemGroup(
    withId groupId: Identifier,
    userIds: [UserId]?,
    userGroupIds: [Identifier]?,
    userAuditLogDetails: AuditLogDetails?,
    origin: UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers.Body.Origin,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func updateItem(with itemId: Identifier, encryptedContent: String, timestamp: SharingTimestamp)
    async throws -> ParsedServerResponse

  func acceptCollection(
    withId collectionId: Identifier,
    userGroupId: Identifier?,
    acceptSignature: String,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func refuseCollection(
    withId collectionId: Identifier,
    userGroupId: Identifier?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func createCollection(
    _ collection: SharingCollection,
    teamId: Int?,
    users: [UserCollectionUpload],
    userGroups: [UserGroupCollectionInvite]?
  ) async throws -> ParsedServerResponse

  func deleteCollection(
    withId collectionId: Identifier,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func renameCollection(
    withId collectionId: Identifier,
    name: String,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func updateOnCollection(
    withId collectionId: Identifier,
    users: [UserCollectionUpdate]?,
    userGroups: [UserGroupCollectionUpdate]?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func inviteOnCollection(
    withId collectionId: Identifier,
    users: [UserCollectionUpload]?,
    userGroups: [UserGroupCollectionInvite]?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func revokeOnCollection(
    withId collectionId: Identifier,
    userIds: [UserId]?,
    userGroupIds: [Identifier]?,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func addItemGroupsInCollection(
    withId collectionId: Identifier,
    itemGroups: [UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection.Body
      .ItemGroupsElement],
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func removeItemGroupsFromCollection(
    withId collectionId: Identifier,
    itemGroupIds: [Identifier],
    revision: SharingRevision,
    itemGroupAuditLogs: [UserDeviceAPIClient.SharingUserdevice.RemoveItemGroupsFromCollection.Body
      .ItemGroupAuditLogsElement]?
  ) async throws -> ParsedServerResponse

  func acceptUserGroup(
    withId groupId: Identifier,
    acceptSignature: String,
    revision: SharingRevision
  ) async throws -> ParsedServerResponse

  func refuseUserGroup(withId groupId: Identifier, revision: SharingRevision) async throws
    -> ParsedServerResponse

  func resendInvite(
    to users: [UserInviteResend],
    forGroupId groupId: Identifier,
    emailsInfo: [EmailInfo],
    revision: SharingRevision) async throws

  func updateOnUserGroup(
    withId groupId: Identifier,
    users: [UserUpdate],
    revision: SharingRevision
  ) async throws -> ParsedServerResponse
}

public struct FetchRequest: Equatable {
  static let sliceSize = 100

  var itemGroupIds: [[Identifier]]
  var itemIds: [[Identifier]]
  var userGroupIds: [[Identifier]]
  var collectionIds: [[Identifier]]
  var isEmpty: Bool {
    return itemGroupIds.isEmpty && itemIds.isEmpty && userGroupIds.isEmpty && collectionIds.isEmpty
  }

  public init(
    itemGroupIds: [Identifier],
    itemIds: [Identifier],
    userGroupIds: [Identifier],
    collectionIds: [Identifier]
  ) {
    self.itemGroupIds = itemGroupIds.chunked(into: FetchRequest.sliceSize)
    self.itemIds = itemIds.chunked(into: FetchRequest.sliceSize)
    self.userGroupIds = userGroupIds.chunked(into: FetchRequest.sliceSize)
    self.collectionIds = collectionIds.chunked(into: FetchRequest.sliceSize)
  }
}

public typealias RawPublicKey = String

@Loggable
public struct SharingInvalidActionError: Error {
  @Loggable
  public enum InvalidType {
    case item
    case itemGroup
    case userGroup
    case collection
  }

  let id: Identifier
  let `type`: InvalidType
}
