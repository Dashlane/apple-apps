import DashTypes
import Foundation

public struct SyncDBStack: SyncableDatabase {
  let driver: DatabaseDriver
  let transactionCryptoEngine: CryptoEngine
  public let acceptedTypes: Set<PersonalDataContentType> = Set(PersonalDataContentType.allCases)
  private let historyUpdater: HistoryUpdater

  public init(
    driver: DatabaseDriver, transactionCryptoEngine: CryptoEngine, historyUserInfo: HistoryUserInfo
  ) {
    self.driver = driver
    self.transactionCryptoEngine = transactionCryptoEngine
    self.historyUpdater = HistoryUpdater(info: historyUserInfo)
  }

  public func parse(
    fromEncryptedTransactionData data: Data,
    identifier: Identifier,
    type: PersonalDataContentType,
    timestamp: Timestamp
  ) throws -> PersonalDataRecord? {
    let deciphered = try data.decrypt(using: transactionCryptoEngine)
    var record = try PersonalDataRecord(id: identifier, compressedXMLData: deciphered)
    record.metadata.lastSyncTimestamp = timestamp
    return record
  }

  public func update(
    withIncomingItems incomingItems: [PersonalDataRecord],
    removedItemIds: [Identifier],
    shouldMerge: Bool
  ) throws {
    guard !incomingItems.isEmpty || !removedItemIds.isEmpty else {
      return
    }

    try driver.write(shouldSyncChange: false) { db in
      if shouldMerge {
        for remoteRecord in incomingItems {
          guard let local = try db.fetchOne(with: remoteRecord.id) else {
            try db.insert(remoteRecord)
            continue
          }

          var metadata = local.metadata
          metadata.lastSyncTimestamp = remoteRecord.metadata.lastSyncTimestamp

          switch local.metadata.syncStatus {
          case .pendingUpload:
            let snapshot = try db.fetchOneSnapshot(with: remoteRecord.id)

            let mergedContent = local.content.merging(
              withRemoteCollection: remoteRecord.content,
              snapshotCollection: snapshot?.content ?? [:])

            let mergedRecord = PersonalDataRecord(metadata: metadata, content: mergedContent)

            try db.update(mergedRecord, shouldCreateSnapshot: true)

            try? historyUpdater.updateIfNeeded(
              forNewRecord: mergedRecord,
              previousRecord: local,
              in: &db)
          case .pendingRemove, nil:
            metadata.syncStatus = nil
            let mergedRecord = PersonalDataRecord(metadata: metadata, content: remoteRecord.content)

            try db.update(mergedRecord, shouldCreateSnapshot: true)
          }
        }
      } else if !incomingItems.isEmpty {
        try db.insert(incomingItems, shouldCreateSnapshot: true)
      }

      if !removedItemIds.isEmpty {
        try db.delete(with: removedItemIds)
      }
    }
  }

  public func prepareUploadTransactionsSession() throws -> UploadTransactionSession {
    return try driver.read { db in
      let updatedRecords = try db.fetchAll(by: .pendingUpload)
      let deletedRecords = try db.fetchAll(by: .pendingRemove)

      let uploadedTransactions: [UploadTransactionSession.Transaction] = try updatedRecords.map {
        record in
        let content =
          try record
          .compressedXMLData()
          .encrypt(using: transactionCryptoEngine)
          .base64EncodedString()

        return .init(
          id: record.id, type: record.metadata.contentType, action: .upload(content: content))

      }

      let deletedTransactions: [UploadTransactionSession.Transaction] = deletedRecords.map {
        record in
        return .init(id: record.id, type: record.metadata.contentType, action: .remove)
      }

      let updatedIds = updatedRecords.compactMap(\.metadata.syncRequestId)
      let deletedIds = deletedRecords.compactMap(\.metadata.syncRequestId)

      return UploadTransactionSession(
        transactionsToUpload: uploadedTransactions + deletedTransactions,
        removedSyncIds: deletedIds,
        updatedSyncIds: updatedIds)
    }
  }

  public func close(_ session: UploadTransactionSession, with summary: TimestampByIds) throws {
    try driver.write(shouldSyncChange: false) { db in
      for syncId in session.updatedSyncRequestIds {
        try db.updateMetadata(forSyncRequestId: syncId, shouldCreateSnapshot: true) { metadata in
          metadata.clearSyncStatus()
          metadata.lastSyncTimestamp = summary[metadata.id]
        }
      }

      if !session.removedSyncRequestIds.isEmpty {
        try db.delete(withSyncRequestIds: session.removedSyncRequestIds)
      }
    }
  }

  public func makeLocalDataSummary() throws -> [TimestampIdPair] {
    try driver.read { db in
      return try db.fetchAllMetadata()
        .compactMap { metadata in
          guard let timestamp = metadata.lastSyncTimestamp else {
            return nil
          }
          return TimestampIdPair(id: metadata.id, timestamp: timestamp)
        }
    }
  }

  public func markAsPendingUploadItems(withIds ids: [Identifier]) throws {
    try driver.write(shouldSyncChange: false) { db in
      try db.updateSyncStatus(.pendingUpload, for: ids)
    }
  }

  public func hasAlreadySync() -> Bool {
    do {
      return try driver.read {
        try $0.count(for: .settings) != 0
      }
    } catch {
      return false
    }
  }
}
