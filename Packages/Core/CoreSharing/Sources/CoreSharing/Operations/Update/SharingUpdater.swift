import CyrilKit
import DashTypes
import Foundation

@SharingActor
struct SharingUpdater {
  let userId: UserId
  let userKeyProvider: UserKeyProvider
  let database: SharingOperationsDatabase
  let sharingClientAPI: SharingClientAPI
  let groupKeyProvider: GroupKeyProvider
  let cryptoProvider: SharingCryptoProvider
  let logger: Logger
  let personalDataDB: SharingPersonalDataDB
  let autoRevokeUsersWithInvalidProposeSignature: Bool

  init(
    userId: UserId,
    userKeyProvider: @escaping UserKeyProvider,
    groupKeyProvider: GroupKeyProvider,
    sharingClientAPI: SharingClientAPI,
    database: SharingOperationsDatabase,
    cryptoProvider: SharingCryptoProvider,
    personalDataDB: SharingPersonalDataDB,
    autoRevokeUsersWithInvalidProposeSignature: Bool,
    logger: Logger
  ) {
    self.userId = userId
    self.userKeyProvider = userKeyProvider
    self.database = database
    self.sharingClientAPI = sharingClientAPI
    self.personalDataDB = personalDataDB
    self.groupKeyProvider = groupKeyProvider
    self.cryptoProvider = cryptoProvider
    self.autoRevokeUsersWithInvalidProposeSignature = autoRevokeUsersWithInvalidProposeSignature
    self.logger = logger
  }

  func update(for request: UpdateRequest, maxIteration: Int = 5) async throws {
    var iteration: Int = 0
    var currentRequest = request
    repeat {
      currentRequest = try await update(for: currentRequest)

      iteration += 1
    } while !currentRequest.isEmpty && iteration < maxIteration
  }

  private func update(for request: UpdateRequest) async throws -> UpdateRequest {
    var request = request
    logger.info("Sharing update starting for request \(request)")

    let response = try await sharingClientAPI.fetch(request)
    request += response
    logger.log(response)

    var nextRequest = UpdateRequest()

    _ = try verifyAndSave(request.userGroups.entitiesToUpdate)
    try database.deleteUserGroups(withIds: request.userGroups.idsToDelete)
    let allUserGroups = try database.fetchAllUserGroups()

    try verifyAndSave(request.collections.entitiesToUpdate)
    try database.deleteCollections(withIds: request.collections.idsToDelete)
    let allCollections = try database.fetchAllCollections()

    let (insertedOrUpdatedItemGroups, invalidProposeSignatureItemGroups) = try verifyAndSave(
      request.itemGroups.entitiesToUpdate)
    try database.deleteItemGroups(withIds: request.itemGroups.idsToDelete)
    let allItemGroups = try database.fetchAllItemGroups()

    try await deleteItemGroupsWithoutCurrentUser(from: allItemGroups)
    try await deleteItemGroupsWithCurrentUserAloneAdmin(
      from: allItemGroups, nextRequest: &nextRequest)
    try await autoRevokeUsersWithInvalidProposeSignature(
      in: invalidProposeSignatureItemGroups, nextRequest: &nextRequest)

    let updateRequest = PersonalDataUpdateRequest(
      itemGroups: insertedOrUpdatedItemGroups,
      contents: request.items.entitiesToUpdate
    )
    try await updatePersonalDataItems(for: updateRequest, allItemGroups: allItemGroups)

    try await personalDataDB.delete(with: request.items.idsToDelete)
    try database.deleteItemContentCaches(withIds: request.items.idsToDelete)

    try await uploadChangesFromPersonalData(in: allItemGroups, nextRequest: &nextRequest)

    try await autoAcceptUserGroupsAndSendKeyToNewUsers(in: allItemGroups, nextRequest: &nextRequest)
    try await autoAcceptUserGroupsAndSendKeyToNewUsers(
      in: allCollections, nextRequest: &nextRequest)
    try await sendKeyToNewUsers(in: allUserGroups, nextRequest: &nextRequest)

    logger.info("Sharing update finished")

    return nextRequest
  }
}

public enum SharingUpdaterError: Error {
  case unknownSharedItem
  case missingTimestampInServerResponse
  case maximumLoopExecutionReached
  case sharingLimitReached
  case missingPendingItem
}
