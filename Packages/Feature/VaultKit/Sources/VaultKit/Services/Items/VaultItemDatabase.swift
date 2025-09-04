import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreTeamAuditLogs
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import UserTrackingFoundation

public struct VaultItemDatabase: VaultItemDatabaseProtocol {
  private let logger: Logger
  private let database: ApplicationDatabase
  private let sharingService: SharedVaultHandling
  private let userSpacesService: UserSpacesService
  private let featureService: FeatureServiceProtocol
  private let teamAuditLogsService: TeamAuditLogsServiceProtocol
  private let cloudPasskeyService: UserSecureNitroEncryptionAPIClient.Passkeys

  private let updateLastUseQueue = DispatchQueue(
    label: "updateLastLocalUseDateQueue", qos: .background)

  public init(
    logger: Logger,
    database: ApplicationDatabase,
    sharingService: SharedVaultHandling,
    featureService: FeatureServiceProtocol,
    userSpacesService: UserSpacesService,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    cloudPasskeyService: UserSecureNitroEncryptionAPIClient.Passkeys
  ) {
    self.logger = logger
    self.database = database
    self.sharingService = sharingService
    self.featureService = featureService
    self.userSpacesService = userSpacesService
    self.teamAuditLogsService = teamAuditLogsService
    self.cloudPasskeyService = cloudPasskeyService
  }

  public func itemsPublisher<Output: VaultItem>(for output: Output.Type) -> AnyPublisher<
    [Output], Never
  > {
    let userSpacesService = userSpacesService
    return database.itemsPublisher(for: output)
      .combineLatest(userSpacesService.$configuration)
      .map { items, configuration in
        items.compactMap { configuration.itemWithSpaceUpdated(on: $0) }
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func itemPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<Output, Never>
  {
    let userSpacesService = userSpacesService
    return database.itemPublisher(for: vaultItem.id, type: Output.self)
      .handleEvents(receiveCompletion: { [logger] completion in
        guard case let .failure(error) = completion else {
          return
        }
        logger.fatal("Vault Item Publisher Failed", error: error)
      })
      .ignoreError()
      .combineLatest(userSpacesService.$configuration)
      .compactMap { item, configuration in
        configuration.itemWithSpaceUpdated(on: item)
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func fetchedPersonalData<Output: VaultItem>(for output: Output.Type)
    -> FetchedPersonalData<Output>
  {
    return database.fetchedPersonalData(for: output)
  }

  @discardableResult
  public func save<Item: VaultItem>(_ item: Item) throws -> Item {
    teamAuditLogsService.logSave(item)
    return try database.save(item)
  }

  @discardableResult
  public func save<Item: VaultItem>(_ items: [Item]) throws -> [Item] {
    teamAuditLogsService.logSave(items)
    return try database.save(items)
  }

  public func dispatchDelete(_ vaultItem: VaultItem) {
    Task {
      try await self.delete(vaultItem)
    }
  }

  public func delete(_ vaultItem: VaultItem) async throws {
    do {
      if vaultItem.isShared {
        try await sharingService.refuseAndDelete(vaultItem)
      } else {
        if case let VaultItemEnumeration.passkey(passkey) = vaultItem.enumerated {
          try await cloudPasskeyService.deletePasskeyIfNeeded(passkey, logger: logger)
        }

        try database.delete(vaultItem)
        try? database.removeFromCollectionsIfNeeded(vaultItem)
      }

      teamAuditLogsService.logDelete(vaultItem)
    } catch {
      logger.error("Can't delete vault item", error: error)
      throw error
    }
  }

  public func count<Item: PersonalDataCodable>(for type: Item.Type) throws -> Int {
    return try database.count(for: type)
  }

  @discardableResult
  public func link(_ generatedPassword: GeneratedPassword, to credential: Credential) throws
    -> GeneratedPassword
  {
    var generatedPassword = generatedPassword
    generatedPassword.link(to: credential)
    return try database.save(generatedPassword)
  }

  public func fetch<Output: VaultItem>(with identifier: Identifier, type: Output.Type) throws
    -> Output?
  {
    guard let item = try database.fetch(with: identifier, type: type) else { return nil }
    return userSpacesService.configuration.itemWithSpaceUpdated(on: item)
  }

  public func updateLastUseDate(of items: [VaultItem], origin: Set<LastUseUpdateOrigin>) {
    updateLastUseQueue.async {
      do {
        try self.database.updateLastUseDate(for: items.map(\.id), origin: origin)
      } catch {
        self.logger.error("Can't update last use", error: error)
      }
    }
  }

  public func sharedItem(with id: Identifier) -> VaultItem? {
    guard let item = try? database.sharedItem(for: id) as? VaultItem else { return nil }
    return userSpacesService.configuration.itemWithSpaceUpdated(on: item)
  }
}

extension UserSpacesService.SpacesConfiguration {
  fileprivate func itemWithSpaceUpdated<Output: VaultItem>(on item: Output) -> Output? {
    guard let spaceId = virtualUserSpace(for: item)?.personalDataId else {
      return nil
    }
    guard spaceId != item.spaceId else {
      return item
    }
    var updatedItem = item
    updatedItem.spaceId = spaceId
    return updatedItem
  }
}

extension ApplicationDatabase {
  fileprivate func removeFromCollectionsIfNeeded(_ item: VaultItem) throws {
    let collections = try fetchAll(PrivateCollection.self)
    let updatedCollections = collections.filter(by: item).map { collection in
      var collectionCopy = collection
      collectionCopy.remove(item)
      return collectionCopy
    }

    try save(updatedCollections)
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  private func deletePasskey(_ passkey: Passkey.CloudPasskey, logger: Logger) async throws {
    do {
      try await deletePasskey(passkeyId: passkey.passkeyId, encryptionKey: passkey.encryptionKey)
    } catch let error as NitroEncryptionError where error.hasPasskeysCode(.passkeyNotFound) {
    } catch let error as NitroEncryptionError {
      logger.fatal("Can't delete cloud passkey \(passkey.passkeyId)", error: error)
      throw error
    }
  }

  fileprivate func deletePasskeyIfNeeded(_ passkey: Passkey, logger: Logger) async throws {
    guard let mode = try? passkey.mode,
      case let Passkey.Mode.cloud(cloudPasskey) = mode
    else {
      return
    }
    try await deletePasskey(cloudPasskey, logger: logger)
  }
}
