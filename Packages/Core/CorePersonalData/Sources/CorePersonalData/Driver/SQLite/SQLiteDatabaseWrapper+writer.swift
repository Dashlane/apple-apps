import DashTypes
import Foundation
import GRDB

extension SQLiteDatabaseWrapper: DatabaseWriter {
  public mutating func save(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws {
    try records
      .map(coder.encode)
      .forEach { record in
        try record.save(db)
        if shouldCreateSnapshot {
          try SQLiteRawSnapshot(id: record.id, encryptedContent: record.encryptedContent).save(db)
        }
      }

    changes.formUnion(records.map(DatabaseChange.init))
  }

  public mutating func insert(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws {
    try records
      .map(coder.encode)
      .forEach { record in
        try record.insert(db)
        if shouldCreateSnapshot {
          try SQLiteRawSnapshot(id: record.id, encryptedContent: record.encryptedContent).insert(db)
        }
      }

    changes.formUnion(records.map(DatabaseChange.init))
  }

  public mutating func update(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws {
    try records
      .map(coder.encode)
      .forEach { record in
        try record.update(db)
        if shouldCreateSnapshot {
          try SQLiteRawSnapshot(id: record.id, encryptedContent: record.encryptedContent).save(db)
        }
      }

    changes.formUnion(records.map(DatabaseChange.init))
  }

  public mutating func update(_ metadata: RecordMetadata) throws {
    try metadata.update(db)
    changes.insert(DatabaseChange(kind: .metadataUpdated, id: metadata.id))
  }

  public mutating func updateMetadata(
    forSyncRequestId syncRequestId: String, shouldCreateSnapshot: Bool,
    using updater: (inout RecordMetadata) -> Void
  ) throws {
    guard
      let rawRecord = try RawRecord.filter(MetadataColumns.syncRequestId == syncRequestId).fetchOne(
        db)
    else {
      return
    }
    var metadata = rawRecord.metadata
    updater(&metadata)
    try update(metadata)
    if shouldCreateSnapshot {
      try SQLiteRawSnapshot(id: rawRecord.id, encryptedContent: rawRecord.encryptedContent).save(db)
    }
  }

  public mutating func insert(_ snapshot: PersonalDataSnapshot) throws {
    let encoded = try coder.encode(snapshot)
    try SQLiteRawSnapshot(id: encoded.id, encryptedContent: encoded.encryptedContent).insert(db)
  }

  public mutating func delete(with ids: [Identifier]) throws {
    try RawRecord.deleteAll(db, ids: ids)
    try RawSnapshot.deleteAll(db, ids: ids)

    changes.formUnion(
      ids.map {
        DatabaseChange(kind: .deleted, id: $0)
      })
  }

  public mutating func delete(withSyncRequestIds syncIds: [String]) throws {
    let ids = try syncIds.compactMap {
      try fetchOneMetadata(withSyncRequestId: $0)?.id
    }

    try delete(with: ids)
  }

  public func clearPending(withSharingUploadIds sharingIds: [String]) throws {
    try RecordMetadata
      .filter(sharingIds.contains(MetadataColumns.pendingSharingUploadId))
      .updateAll(db, [MetadataColumns.pendingSharingUploadId.set(to: nil)])
  }
}
