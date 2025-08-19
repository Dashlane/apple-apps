import Combine
import CoreData
import CoreSession
import CoreSync
import CoreTypes
import Foundation
import SwiftTreats

#if !targetEnvironment(macCatalyst)

  class SpiegelStoreMigrater {
    struct Setting {
      @SharedUserDefault(key: "SpiegelStoreMigrater.isRestoringMode", default: false)
      var isRestoringMode: Bool
    }

    enum HistoryEntity {
      case dataChangeHistory
      case changeSet

      var entityName: String {
        switch self {
        case .dataChangeHistory:
          return "KWDataChangeHistory"
        case .changeSet:
          return "KWChangeSet"
        }
      }

      var contentKey: String {
        switch self {
        case .dataChangeHistory:
          return "dataChangeHistory"
        case .changeSet:
          return "changeSets"
        }
      }
    }

    let session: Session
    let appSettings: AppSettings
    let spiegelDataBaseURL: URL
    let storeURL: URL
    let logger: Logger
    var setting = Setting()
    let forceRestoringMode: Bool

    init(
      session: Session,
      appSettings: AppSettings,
      spiegelDataBaseURL: URL,
      storeURL: URL,
      logger: Logger,
      forceRestoringMode: Bool
    ) {
      self.session = session
      self.appSettings = appSettings
      self.spiegelDataBaseURL = spiegelDataBaseURL
      self.storeURL = storeURL
      self.logger = logger
      self.forceRestoringMode = forceRestoringMode
    }

    var isRestoringMode: Bool {
      return setting.isRestoringMode || forceRestoringMode
    }
    func migrate() throws {
      guard FileManager.default.fileExists(atPath: spiegelDataBaseURL.path) else {
        logger.info("Nothing to migrate")
        return
      }

      let fiberStoreExists = FileManager.default.fileExists(atPath: storeURL.path)

      guard isRestoringMode || !fiberStoreExists else {
        logger.info(
          "Nothing to do, store already exists and we are not in the forced restoring mode")
        return
      }

      guard let model = CoreDataUtilities.model(withName: "DashlanePersonalDataModel") else {
        assertionFailure("Core Data model should exist")
        return
      }
      let entitiesByName = model.entitiesByName

      guard let entitiesHistory = entitiesByName[HistoryEntity.dataChangeHistory.entityName],
        let entitiesChangeSet = entitiesByName[HistoryEntity.changeSet.entityName]
      else {
        assertionFailure("Core Data Base entities should exist")
        return
      }

      do {
        logger.info("migration of Spiegel DB started")
        let spiegelDataBase = try loadDatabase(locatedAt: spiegelDataBaseURL)

        let syncStatus =
          try spiegelDataBase
          .loadTransactionActions()
          .mapValues { $0.linkedSyncStatus }
        logger.info("pendingSync: \(syncStatus)")

        let regularNodes: [Node] =
          try spiegelDataBase
          .loadDataRows(
            for: model.entities.filter { $0 != entitiesHistory && $0 != entitiesChangeSet }
          )
          .map { row in
            Node(
              id: row.id,
              entityName: row.entityName,
              propertyCache: row.content,
              syncStatus: syncStatus[row.id, default: nil])
          }

        let changeSetNodes = try spiegelDataBase.loadDataRows(for: [entitiesChangeSet])
          .map { row in
            return Node(
              id: row.id,
              entityName: row.entityName,
              propertyCache: transformChangeSetContent(row.content))
          }

        let historyNodes = try spiegelDataBase.loadDataRows(for: [entitiesHistory])
          .map { row in
            return Node(
              id: row.id,
              entityName: row.entityName,
              propertyCache: transformHistoryContent(row.content, changeSetNodes: changeSetNodes),
              orderedPropertyCacheKeys: [HistoryEntity.changeSet.contentKey],
              syncStatus: syncStatus[row.id, default: nil])
          }

        let nodes = regularNodes + changeSetNodes + historyNodes
        logger.info("\(nodes.count) objects will be migrated")

        try save(nodes)
        logger.info("Migration of Spiegel DB finished successfully")
      } catch {
        logger.error("Migration from Spiegel DB failed", error: error)
        throw error
      }
    }

    private func loadDatabase(locatedAt location: URL) throws -> SpiegelSQLCipheredDatabase {
      do {
        let localKey = session.localKey

        return try SpiegelSQLCipheredDatabase(
          filePath: location.absoluteString, storeEncryption: .key(localKey))
      } catch {
        guard let password = self.session.configuration.masterKey.masterPassword else {
          throw error
        }
        return try SpiegelSQLCipheredDatabase(
          filePath: location.absoluteString, storeEncryption: .password(password))
      }
    }

    private func transformChangeSetContent(_ content: [String: Any]) -> [String: Any] {
      var content = content

      if let historyContent = content[HistoryEntity.dataChangeHistory.contentKey] as? [String: Any]
      {
        content[HistoryEntity.dataChangeHistory.contentKey] =
          Node(
            entityName: HistoryEntity.dataChangeHistory.entityName,
            propertyCache: historyContent.filter { $0.key != HistoryEntity.changeSet.contentKey }
          )
          .jsonDictionary
      }

      return content
    }

    private func transformHistoryContent(_ content: [String: Any], changeSetNodes: [Node])
      -> [String: Any]
    {
      var changeSetsById = [String: [String: Any]]()
      for set in changeSetNodes {
        changeSetsById[set.id] = set.propertyCache.filter {
          $0.key != HistoryEntity.dataChangeHistory.contentKey
        }
      }

      var content = content
      if let changesSets = content[HistoryEntity.changeSet.contentKey] as? [String: Any] {
        content[HistoryEntity.changeSet.contentKey] = changesSets.compactMap {
          id, _ -> [AnyHashable: Any]? in
          guard let content = changeSetsById["{" + id + "}"] else {
            return nil
          }
          return Node(
            entityName: HistoryEntity.changeSet.entityName,
            propertyCache: content
          ).jsonDictionary
        }
      }

      return content
    }

    private func save(_ nodes: [Node]) throws {
      let store = session.store(for: SyncService.SyncStoreKey.self)
      try store.store(nodes.lastBackupDate().rawValue, for: .lastSyncTimestamp)

      let jsonDict =
        nodes
        .filter { !$0.id.isEmpty }
        .map { $0.jsonDictionary }

      let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted])
      guard let secureCacheNodeData = session.localCryptoEngine.encrypt(data: jsonData) else {
        throw SimpleSecureStoreError.couldNotEncryptStore
      }

      try secureCacheNodeData.write(to: storeURL)
    }

  }

  extension SpiegelStoreMigrater {

    static func migratePublisher(
      session: Session,
      loadingContext: SessionLoadingContext,
      appSettings: AppSettings,
      storeURL: URL,
      logger: Logger,
      forceRestoringMode: Bool = false
    ) -> Future<Void, Error> {

      return Future<Void, Error> { completion in
        guard loadingContext == .localLogin else {
          completion(.success)
          return
        }

        DispatchQueue.global(qos: .userInitiated).async {
          let migrater = SpiegelStoreMigrater(
            session: session,
            appSettings: appSettings,
            spiegelDataBaseURL: session.spiegelDataBaseURL,
            storeURL: storeURL,
            logger: logger,
            forceRestoringMode: forceRestoringMode)

          let result = Result { try migrater.migrate() }
          DispatchQueue.main.async {
            if result.isFailure && !migrater.setting.isRestoringMode {
              logger.error("Migration fail, attempting to sync to fetch user data.")
              completion(.success)
            } else {
              migrater.setting.isRestoringMode = false
              completion(result)
            }

          }
        }
      }
    }
  }

  extension Session {
    var spiegelDataBaseURL: URL {
      guard let md5Login = login.email.md5() else {
        fatalError("can't MD5 Hash")
      }
      let dataVersion = 8
      let fileName = "\(md5Login).v\(dataVersion).db"
      let url = ApplicationGroup.documentsURL.appendingPathComponent(fileName)
      return url
    }
  }

  extension SyncTransactionActionType {
    fileprivate var linkedSyncStatus: SyncStatus? {
      switch self {
      case .edit:
        return .pendingUploadItemChanged
      case .remove:
        return .pendingUploadItemRemoved
      case .unknown:
        return nil
      }
    }
  }

  extension Array where Element == SpiegelStoreMigrater.Node {
    func lastBackupDate() -> Timestamp {
      return reduce(Timestamp.distantPast) { result, node in
        guard let rawDateString = node.propertyCache["backupDate"] as? String,
          let rawDate = UInt64(rawDateString)
        else {
          return result
        }

        return Swift.max(Timestamp(rawDate), result)
      }
    }
  }

#endif
