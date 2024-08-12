import Combine
import CoreActivityLogs
import CorePersonalData
import CorePremium
import CoreSharing
import CoreUserTracking
import DashTypes
import Foundation

public final class VaultCollectionDatabase: VaultKitServicesInjecting,
  VaultCollectionDatabaseProtocol
{

  @Published private var sharedCollections: [SharedCollectionItems] = []

  private let logger: Logger
  private let database: ApplicationDatabase
  private let sharingService: SharingServiceProtocol
  private let userSpacesService: UserSpacesService
  private let activityReporter: ActivityReporterProtocol
  private let activityLogsService: ActivityLogsServiceProtocol
  private let vaultTipDonator: VaultTipDonator

  public init(
    logger: Logger,
    database: ApplicationDatabase,
    sharingService: SharingServiceProtocol,
    userSpacesService: UserSpacesService,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol
  ) {
    self.logger = logger
    self.database = database
    self.sharingService = sharingService
    self.userSpacesService = userSpacesService
    self.activityReporter = activityReporter
    self.activityLogsService = activityLogsService
    self.vaultTipDonator = .init()

    configurePublishers()
  }

  private func configurePublishers() {
    sharingService
      .sharingCollectionsPublisher()
      .assign(to: &$sharedCollections)
  }

  public func collectionsPublisher() -> AnyPublisher<[VaultCollection], Never> {
    return
      database
      .itemsPublisher(for: PrivateCollection.self)
      .map { Array($0) }
      .shareReplayLatest()
      .combineLatest($sharedCollections) { [weak self] privateCollections, sharedCollections in
        let abstractedPrivateCollections = privateCollections.map(VaultCollection.init(collection:))
        let abstractedSharedCollections = sharedCollections.compactMap { collection in
          self?.makeVaultCollection(collection)
        }
        let collections = abstractedPrivateCollections + abstractedSharedCollections

        if !collections.isEmpty {
          self?.vaultTipDonator.donateCollectionCreation()
        }

        return collections.sortedByName()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  private func makeVaultCollection(_ collectionItems: SharedCollectionItems) -> VaultCollection {
    VaultCollection(
      collectionItems: collectionItems,
      spaceId: userSpacesService.configuration.currentTeam?.personalDataId
    )
  }

  @discardableResult
  public func createPrivateCollection(
    _ collection: VaultCollection,
    named: String
  ) async throws -> VaultCollection {
    guard case .private(var collection) = collection.type else { return collection }

    collection.name = named

    return try await save(.init(collection: collection))
  }

  public func save(_ collection: VaultCollection) async throws -> VaultCollection {
    vaultTipDonator.donateCollectionCreation()

    switch collection.type {
    case .private(let collection):
      activityLogsService.logCreate(collection)
      return VaultCollection(collection: try database.save(collection))
    case .shared(let collectionItems, _):
      return VaultCollection(
        collectionItems: try await save(collectionItems),
        spaceId: collection.spaceId
      )
    }
  }

  private func save(_ collectionItems: SharedCollectionItems) async throws -> SharedCollectionItems
  {
    guard
      let previousCollectionItems = sharedCollections.first(where: { $0.id == collectionItems.id })
    else {
      return collectionItems
    }

    if collectionItems.itemIds != previousCollectionItems.itemIds {
      let difference = collectionItems.itemIds.difference(from: previousCollectionItems.itemIds)
      let insertions: [Identifier] = difference.insertions.compactMap { insertion in
        guard case .insert(_, let element, _) = insertion else { return nil }
        return element
      }
      let removals: [Identifier] = difference.removals.compactMap { insertion in
        guard case .remove(_, let element, _) = insertion else { return nil }
        return element
      }
      if !insertions.isEmpty {
        try await sharingService.addItemsToCollection(
          withId: collectionItems.id, itemIds: insertions)
      }
      if !removals.isEmpty {
        try await sharingService.removeItemsFromCollection(
          withId: collectionItems.id, itemIds: removals)
      }
    }

    if collectionItems.collection.name != previousCollectionItems.collection.name {
      try await sharingService.renameCollection(
        withId: collectionItems.id,
        name: collectionItems.collection.name
      )
    }

    return collectionItems
  }

  public func dispatchDelete(_ collection: VaultCollection) {
    Task {
      try await self.delete(collection)
    }
  }

  public func delete(_ collection: VaultCollection) async throws {
    try await delete(collection, wasShared: false)
  }

  private func delete(_ collection: VaultCollection, wasShared: Bool) async throws {
    switch collection.type {
    case .private(let collection):
      try delete(collection, wasShared: wasShared)
    case .shared(let collection, _):
      try await delete(collection)
    }
  }

  private func delete(_ collection: PrivateCollection, wasShared: Bool) throws {
    do {
      try database.delete(collection)
      if !wasShared {
        activityLogsService.logDelete(collection)
        activityReporter.report(
          UserEvent.UpdateCollection(
            action: .delete,
            collectionId: collection.id.rawValue,
            isShared: collection.isShared,
            itemCount: collection.items.count
          )
        )
      }
    } catch {
      logger[.personalData].error("Error on save", error: error)
      throw error
    }
  }

  private func delete(_ collection: SharedCollectionItems) async throws {
    try await sharingService.deleteCollection(withId: collection.id)
  }

  public func share(
    _ collections: [VaultCollection],
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission
  ) async throws {
    func deletePrivateCollections() async throws {
      try await collections.asyncForEach { try await delete($0, wasShared: true) }
    }

    do {
      try await sharingService.share(
        collections,
        teamId: teamId,
        recipients: recipients,
        userGroupIds: userGroupIds,
        permission: permission
      )

      try await deletePrivateCollections()
    } catch let error as CollectionsSharingError {
      switch error {
      case .collectionError(let error):
        throw error
      case .addItemsError:
        try await deletePrivateCollections()
      }
    }
  }
}
