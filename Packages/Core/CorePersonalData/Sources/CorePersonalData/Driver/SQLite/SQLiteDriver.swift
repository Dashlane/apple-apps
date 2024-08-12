import Combine
import DashTypes
import DatabaseFoundation
import Foundation
import GRDB
import SwiftTreats

typealias RawRecord = SQLiteRawRecord
typealias RawSnapshot = SQLiteRawSnapshot
typealias MetadataColumns = RecordMetadata.CodingKeys

public struct SQLiteDriver: DatabaseDriver {
  public var eventPublisher: PassthroughSubject<DatabaseEvent, Never> {
    return eventsNotifier.eventPublisher
  }
  public let syncTriggerPublisher = PassthroughSubject<Void, Never>()

  let pool: DatabasePool
  let cryptoEngine: CryptoEngine
  private let eventsNotifier: SQLiteDriverEventNotifier
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  public init(url: URL, cryptoEngine: CryptoEngine, identifier: SQLiteClientIdentifier) throws {
    pool = try DatabasePool.makeShared(databaseURL: url, name: "GalacticaDB")
    self.cryptoEngine = cryptoEngine
    self.eventsNotifier = SQLiteDriverEventNotifier(identifier: identifier)

    try configureTable()
  }

  private func configureTable() throws {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
      try db.create(table: SQLiteRawRecord.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text).primaryKey(onConflict: .replace).collate(.nocase).notNull(
          onConflict: .fail)
        t.column("contentType", .text).notNull(onConflict: .fail).indexed()
        t.column("syncStatus", .text)
        t.column("syncRequestId", .text).indexed()
        t.column("lastSyncTimestamp", .integer)
        t.column("isShared", .boolean).indexed()
        t.column("pendingSharingUploadId", .text)
        t.column("parentId", .text).collate(.nocase).indexed()
        t.column("lastLocalUseDate", .date)
        t.column("lastLocalSearchDate", .date)
        t.column("encryptedContent", .blob)
      }

      try db.create(table: SQLiteRawSnapshot.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text).primaryKey(onConflict: .replace).collate(.nocase).notNull(
          onConflict: .fail)
        t.column("encryptedContent", .blob)
      }
    }

    migrator.registerMigration("v2.sharingRefactor") { db in
      try db.alter(
        table: SQLiteRawRecord.databaseTableName,
        body: { t in
          t.add(column: "sharingPermission", .text)
        })
    }

    try migrator.migrate(pool)
    assert(checkTableStructure())
  }

  private func checkTableStructure() -> Bool {
    do {
      return try pool.read { db in
        let columns = try db.columns(in: SQLiteRawRecord.databaseTableName).map {
          $0.name
        }
        let expected =
          MetadataColumns.allCases.map(\.rawValue)
          + SQLiteRawRecord.CodingKeys.allCases.map(\.rawValue)
        return Set(columns) == Set(expected)
      }
    } catch {
      return false
    }
  }
}

extension SQLiteDriver: SQLiteDataCoder {
  func encode(_ record: PersonalDataRecord) throws -> SQLiteRawRecord {
    guard record.metadata.id != .temporary else {
      throw DatabaseError.cannotSaveTemporaryRecord
    }
    let data = try encoder.encode(record.content)
    let encryptedData = try data.encrypt(using: cryptoEngine)
    return SQLiteRawRecord(info: record.metadata, encryptedContent: encryptedData)
  }

  func decode(_ record: SQLiteRawRecord) throws -> PersonalDataRecord {
    let data = try record.encryptedContent.decrypt(using: cryptoEngine)
    let content = try decoder.decode(PersonalDataCollection.self, from: data)
    return PersonalDataRecord(metadata: record.metadata, content: content)
  }

  func encode(_ snapshot: PersonalDataSnapshot) throws -> SQLiteRawSnapshot {
    let data = try encoder.encode(snapshot.content)
    let encryptedData = try data.encrypt(using: cryptoEngine)
    return SQLiteRawSnapshot(id: snapshot.id, encryptedContent: encryptedData)
  }

  func decode(_ snapshot: SQLiteRawSnapshot) throws -> PersonalDataSnapshot {
    let data = try snapshot.encryptedContent.decrypt(using: cryptoEngine)
    let content = try decoder.decode(PersonalDataCollection.self, from: data)
    return PersonalDataSnapshot(id: snapshot.id, content: content)
  }
}

extension SQLiteDriver {
  private func database(for db: Database) -> SQLiteDatabaseWrapper {
    return .init(db: db, coder: self)
  }

  public func read<T>(_ reader: (DatabaseReader) throws -> T) throws -> T {
    return try pool.read { db in
      try reader(database(for: db))
    }
  }

  public func write<T>(shouldSyncChange: Bool, _ writer: (inout DatabaseWriter) throws -> T) throws
    -> T
  {
    let (output, changes) = try pool.write { db -> (T, Set<DatabaseChange>) in
      var wrapper: DatabaseWriter = database(for: db)
      let output: T = try writer(&wrapper)
      let changes = wrapper.changes
      return (output, changes)
    }

    if !changes.isEmpty {
      eventsNotifier.notify(.incrementalChanges(changes))
    }

    if shouldSyncChange && !changes.isEmpty {
      syncTriggerPublisher.send()
    }

    return output
  }
}
