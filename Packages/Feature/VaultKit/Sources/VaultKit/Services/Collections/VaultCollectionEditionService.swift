import Combine
import CorePersonalData
import CoreSharing
import CoreTeamAuditLogs
import CoreTypes
import LogFoundation
import UserTrackingFoundation

public final class VaultCollectionEditionService: ObservableObject, VaultKitServicesInjecting {

  private(set) var collection: VaultCollection

  private let logger: Logger
  private let activityReporter: ActivityReporterProtocol
  private let teamAuditLogsService: TeamAuditLogsServiceProtocol
  private let sharingService: SharingServiceProtocol
  private let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  private let vaultCollectionsStore: VaultCollectionsStore

  public init(
    collection: VaultCollection,
    logger: Logger,
    activityReporter: ActivityReporterProtocol,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharingServiceProtocol
  ) {
    self.collection = collection
    self.logger = logger
    self.activityReporter = activityReporter
    self.teamAuditLogsService = teamAuditLogsService
    self.vaultCollectionDatabase = vaultCollectionDatabase
    self.vaultCollectionsStore = vaultCollectionsStore
    self.sharingService = sharingService
  }

  public func rename(to name: String) async throws {
    switch collection.type {
    case .private(var collection):
      let oldCollectionName = collection.name
      collection.name = name
      teamAuditLogsService.logRename(collection, oldCollectionName: oldCollectionName)
      self.collection = try await vaultCollectionDatabase.save(.init(collection: collection))
    case .shared(var collectionItems, _):
      collectionItems.collection.name = name
      try await sharingService.renameCollection(withId: collectionItems.id, name: name)
      self.collection = VaultCollection(
        collectionItems: collectionItems, spaceId: collection.spaceId)
    }
  }

  public func delete() async throws {
    try await vaultCollectionDatabase.delete(collection)
  }

  public func add(_ item: VaultItem) async throws {
    try await add([item])
  }

  public func add(_ items: [VaultItem]) async throws {
    var updatedCollection = collection
    items.forEach {
      updatedCollection.insert($0)
    }
    updatedCollection = try await vaultCollectionDatabase.save(updatedCollection)
    self.collection = updatedCollection
  }

  @discardableResult
  public func remove(_ item: VaultItem) async throws -> VaultCollection {
    try await remove([item])
  }

  @discardableResult
  public func remove(_ items: [VaultItem]) async throws -> VaultCollection {
    var updatedCollection = collection
    items.forEach {
      updatedCollection.remove($0)
    }
    updatedCollection = try await vaultCollectionDatabase.save(updatedCollection)
    self.collection = updatedCollection
    return updatedCollection
  }

  public func share(
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission
  ) async throws {
    try await vaultCollectionDatabase.share(
      [collection],
      teamId: teamId,
      recipients: recipients,
      userGroupIds: userGroupIds,
      permission: permission
    )
  }
}

extension VaultCollectionEditionService {
  public static func mock(_ collection: VaultCollection) -> VaultCollectionEditionService {
    VaultCollectionEditionService(
      collection: collection,
      logger: .mock,
      activityReporter: ActivityReporterMock(),
      teamAuditLogsService: .mock(),
      vaultCollectionDatabase: VaultCollectionDatabase.mock(),
      vaultCollectionsStore: VaultCollectionsStoreImpl.mock(),
      sharingService: SharingServiceMock()
    )
  }
}
