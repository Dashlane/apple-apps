import Combine
import CoreCrypto
import CorePersonalData
import CoreSession
import CoreSharing
import CoreSync
import CoreTeamAuditLogs
import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation

public class SharingService: SharingServiceProtocol {
  @Published
  var isReady: Bool = false

  public var manualSyncHandler: () -> Void = {}

  private let userId: UserId
  let personalDataDB: SharingPersonalDataDBStack
  public let engine: SharingEngine<SQLiteDatabase>
  let activityReporter: SharingActivityReporter
  let keysStore: SharingKeysStore
  let teamAuditLogsService: TeamAuditLogsServiceProtocol
  let applicationDatabase: ApplicationDatabase

  public init(
    session: Session,
    apiClient: UserDeviceAPIClient.SharingUserdevice,
    codeDecoder: CodeDecoder,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol,
    databaseDriver: DatabaseDriver,
    sharingKeysStore: SharingKeysStore,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    logger: Logger,
    activityReporter: ActivityReporterProtocol,
    applicationDatabase: ApplicationDatabase,
    buildTarget: BuildTarget
  ) async throws {
    userId = session.login.email
    keysStore = sharingKeysStore
    personalDataDB = SharingPersonalDataDBStack(
      driver: databaseDriver,
      codeDecoder: codeDecoder,
      personalDataURLDecoder: personalDataURLDecoder,
      historyUserInfo: HistoryUserInfo(session: session),
      logger: logger)
    self.activityReporter = activityReporter.sharing

    let cryptoProvider = CyrilSharingCryptoProvider { key in
      try CryptoConfiguration.legacy(.kwc5).makeCryptoEngine(secret: .key(key))
    } symmetricKeyProvider: {
      Data.random(ofSize: 32)
    }

    let folder = try session.directory.storeURL(for: .sharing, in: .app)
    let queue = AsyncDistributedSerialQueue(
      lockId: buildTarget.rawValue, lockFile: folder.appendingPathExtension("lock"),
      maximumLockDuration: 10)
    let key = await sharingKeysStore.keyPair()
    let url = folder.appendingPathComponent("sharing2.db")
    self.teamAuditLogsService = teamAuditLogsService
    self.applicationDatabase = applicationDatabase

    engine = try await SharingEngine(
      url: url,
      userId: session.login.email,
      userKeys: key,
      serialExecutionQueue: queue,
      apiClient: apiClient,
      personalDataDB: personalDataDB,
      cryptoProvider: cryptoProvider,
      logger: logger)
  }

  public func isReadyPublisher() -> AnyPublisher<Bool, Never> {
    return $isReady.eraseToAnyPublisher()
  }
}

extension SharingService {
  public func pendingUserGroupsPublisher() -> AnyPublisher<[PendingUserGroup], Never> {
    return engine.database.pendingUserGroups(for: userId).publisher().replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func pendingItemGroupsPublisher() -> AnyPublisher<[PendingItemGroup], Never> {
    return engine.database.pendingItemGroups(for: userId).publisher().replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func pendingCollectionsPublisher() -> AnyPublisher<[PendingCollection], Never> {
    return engine.database.pendingCollections(for: userId).publisher().replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func sharingCollectionsPublisher() -> AnyPublisher<[SharedCollectionItems], Never> {
    return engine.database.sharingCollections(for: userId).publisher().replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func sharingUserGroupsPublisher() -> AnyPublisher<[SharingEntitiesUserGroup], Never> {
    return engine.database.sharingUserGroups(for: userId).publisher().replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func sharingUsersPublisher() -> AnyPublisher<[SharingEntitiesUser], Never> {
    return engine.database.sharingUsers(for: userId).publisher().replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func sharingMembers(forItemId id: Identifier) -> AnyPublisher<ItemSharingMembers?, Never> {
    return engine.database.sharingMembers(forItemId: id).publisher().replaceError(with: nil)
      .eraseToAnyPublisher()
  }

  public func sharingMembers(forCollectionId id: Identifier) -> AnyPublisher<
    CollectionSharingMembers?, Never
  > {
    return engine.database.sharingMembers(forCollectionId: id).publisher().replaceError(with: nil)
      .eraseToAnyPublisher()
  }
}

extension SharingService {
  public func pendingItemsPublisher() -> AnyPublisher<[Identifier: VaultItem], Never> {
    return personalDataDB.pendingItemsPublisher().map { $0.compactMapValues { $0 as? VaultItem } }
      .eraseToAnyPublisher()
  }

  public func update(spaceId: String, toPendingItem item: VaultItem) {
    personalDataDB.update(spaceId: spaceId, toPendingItemWithId: item.id)
  }
}

extension SharingService {
  public func getTeamLogins() async throws -> [String] {
    return try await engine.getTeamLogins()
  }

  public func accept(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws {
    do {
      let auditLogDetails = try await teamAuditLogsService.auditLogDetails(for: loggedItem)
      try await engine.accept(itemGroupInfo, userAuditLogDetails: auditLogDetails)

      activityReporter.reportPendingItemGroupResponse(
        for: loggedItem, accepted: true, success: true)
    } catch {
      activityReporter.reportPendingItemGroupResponse(
        for: loggedItem, accepted: false, success: false)
      throw error
    }
  }

  public func refuse(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws {
    do {
      let auditLogDetails = try await teamAuditLogsService.auditLogDetails(for: loggedItem)
      try await engine.refuse(itemGroupInfo, userAuditLogDetails: auditLogDetails)
      activityReporter.reportPendingItemGroupResponse(
        for: loggedItem, accepted: false, success: true)
    } catch {
      activityReporter.reportPendingItemGroupResponse(
        for: loggedItem, accepted: false, success: false)
      throw error
    }
  }

  public func accept(_ collectionInfo: CollectionInfo) async throws {
    try await engine.accept(collectionInfo)

    manualSyncHandler()
  }

  public func refuse(_ collectionInfo: CollectionInfo) async throws {
    try await engine.refuse(collectionInfo)
  }

  public func accept(_ groupInfo: UserGroupInfo) async throws {
    try await engine.accept(groupInfo)
  }

  public func refuse(_ groupInfo: UserGroupInfo) async throws {
    try await engine.refuse(groupInfo)
  }

  public func revoke(
    in group: ItemGroupInfo,
    users: [User<ItemGroup>]?,
    userGroupMembers: [UserGroupMember<ItemGroup>]?,
    loggedItem: VaultItem
  ) async throws {
    do {
      let auditLogDetails = try await teamAuditLogsService.auditLogDetails(for: loggedItem)
      try await engine.revoke(
        in: group,
        users: users,
        userGroupMembers: userGroupMembers,
        userAuditLogDetails: auditLogDetails)

      activityReporter.reportRevoke(of: loggedItem, success: true)
    } catch {
      activityReporter.reportRevoke(of: loggedItem, success: false)
      throw error
    }
  }

  public func revoke(
    in collection: CollectionInfo,
    users: [User<SharingCollection>]?,
    userGroupMembers: [UserGroupMember<SharingCollection>]?
  ) async throws {
    try await engine.revoke(
      in: collection,
      users: users,
      userGroupMembers: userGroupMembers
    )
  }

  public func forceRevoke(_ items: [PersonalDataCodable]) async throws {
    try await engine.forceRevokeItemGroup(withItemIds: items.map(\.id))
  }

  public func updatePermission(
    _ permission: SharingPermission,
    of user: User<ItemGroup>,
    in group: ItemGroupInfo,
    loggedItem: VaultItem
  ) async throws {
    do {
      try await engine.updatePermission(
        permission,
        of: user,
        in: group)

      activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: true)
    } catch {
      activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: false)
      throw error
    }
  }

  public func updatePermission(
    _ permission: SharingPermission,
    of userGroupMember: UserGroupMember<ItemGroup>,
    in group: ItemGroupInfo,
    loggedItem: VaultItem
  ) async throws {
    do {
      try await engine.updatePermission(
        permission,
        of: userGroupMember,
        in: group)

      activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: true)

    } catch {
      activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: false)
      throw error
    }
  }

  public func updatePermission(
    _ permission: SharingPermission,
    of user: User<SharingCollection>,
    in collection: CollectionInfo
  ) async throws {
    try await engine.updatePermission(permission, of: user, in: collection)
  }

  public func updatePermission(
    _ permission: SharingPermission,
    of userGroupMember: UserGroupMember<SharingCollection>,
    in collection: CollectionInfo
  ) async throws {
    try await engine.updatePermission(permission, of: userGroupMember, in: collection)
  }

  public func resendInvites(to users: [User<ItemGroup>], in group: ItemGroupInfo) async throws {
    try await engine.resendInvites(to: users, in: group)
  }

  public func share(
    _ items: [VaultItem],
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    limitPerUser: Int?
  ) async throws {
    do {
      let auditLogDetails = try await teamAuditLogsService.auditLogDetails(for: items)
      try await engine.shareItems(
        withIds: items.map(\.id),
        recipients: recipients,
        userGroupIds: userGroupIds,
        permission: permission,
        limitPerUser: limitPerUser,
        userAuditLogDetails: auditLogDetails)

      activityReporter.reportCreate(
        with: items, userRecipients: recipients, userGroupIds: userGroupIds, permission: permission,
        success: true)
    } catch {
      activityReporter.reportCreate(
        with: items, userRecipients: recipients, userGroupIds: userGroupIds, permission: permission,
        success: false)
      throw error
    }
  }

  public func share(
    _ collections: [VaultCollection],
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission
  ) async throws {
    do {
      try await engine.shareCollections(
        withIdNamePairs: collections.map { ($0.id, $0.name) },
        teamId: teamId,
        recipients: recipients,
        userGroupIds: userGroupIds,
        permission: permission,
        userAuditLogDetails: [:]
      )
    } catch {
      throw CollectionsSharingError.collectionError(error)
    }

    do {
      for collection in collections {
        let itemIds = Array(collection.itemIds)
        try await engine.addItemsToCollection(
          withId: collection.id,
          itemIds: itemIds,
          userAuditLogDetails: try await auditLogDetails(for: itemIds))
      }
    } catch {
      throw CollectionsSharingError.addItemsError(
        error
      )
    }
  }

  public func renameCollection(withId collectionId: Identifier, name: String) async throws {
    try await engine.renameCollection(withId: collectionId, name: name)
  }

  public func deleteCollection(withId collectionId: Identifier) async throws {
    try await engine.deleteCollection(withId: collectionId)
  }

  public func addItemsToCollection(withId collectionId: Identifier, itemIds: [Identifier])
    async throws
  {
    try await engine.addItemsToCollection(
      withId: collectionId,
      itemIds: itemIds,
      userAuditLogDetails: try await auditLogDetails(for: itemIds))
    manualSyncHandler()
  }

  public func removeItemsFromCollection(withId collectionId: Identifier, itemIds: [Identifier])
    async throws
  {
    try await engine.removeItemsFromCollection(
      withId: collectionId,
      itemIds: itemIds,
      auditLogDetails: try await self.auditLogDetails(for: itemIds))
    manualSyncHandler()
  }

  private func auditLogDetails(for itemIds: [Identifier]) async throws -> [Identifier:
    AuditLogDetails]
  {
    let credentials =
      (try? applicationDatabase.fetchAll(with: itemIds, type: Credential.self)) ?? []
    return try await teamAuditLogsService.auditLogDetails(for: credentials)
  }
}

@Loggable
enum CollectionsSharingError: Error {
  case collectionError(Error)
  case addItemsError(Error)
}
