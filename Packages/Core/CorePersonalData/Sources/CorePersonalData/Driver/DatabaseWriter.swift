import Combine
import CoreTypes
import Foundation

public protocol DatabaseWriter: DatabaseReader {
  var changes: Set<DatabaseChange> { get }

  mutating func save(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws
  mutating func insert(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws
  mutating func update(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws
  mutating func delete(_ records: [PersonalDataRecord]) throws
  mutating func delete(with ids: [Identifier]) throws
  mutating func delete(withSyncRequestIds ids: [String]) throws
  mutating func clearPending(withSharingUploadIds sharingIds: [String]) throws

  mutating func save(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws
  mutating func insert(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws
  mutating func update(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws
  mutating func update(_ metadata: RecordMetadata) throws
  mutating func updateMetadata(
    forSyncRequestId: String, shouldCreateSnapshot: Bool,
    using updater: (inout RecordMetadata) -> Void) throws
  mutating func delete(_ record: PersonalDataRecord) throws
  mutating func delete(with id: Identifier) throws
  mutating func insert(_ snapshot: PersonalDataSnapshot) throws
}

extension DatabaseWriter {
  public mutating func save(_ records: [PersonalDataRecord]) throws {
    try save(records, shouldCreateSnapshot: false)
  }

  public mutating func insert(_ records: [PersonalDataRecord]) throws {
    try insert(records, shouldCreateSnapshot: false)
  }

  public mutating func update(_ records: [PersonalDataRecord]) throws {
    try update(records, shouldCreateSnapshot: false)
  }

  public mutating func save(_ record: PersonalDataRecord) throws {
    try save(record, shouldCreateSnapshot: false)
  }

  public mutating func insert(_ record: PersonalDataRecord) throws {
    try insert(record, shouldCreateSnapshot: false)
  }

  public mutating func update(_ record: PersonalDataRecord) throws {
    try update(record, shouldCreateSnapshot: false)
  }
}

extension DatabaseWriter {
  public mutating func save(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws {
    try save([record], shouldCreateSnapshot: shouldCreateSnapshot)
  }

  public mutating func insert(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws {
    try insert([record], shouldCreateSnapshot: shouldCreateSnapshot)
  }

  public mutating func update(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws {
    try update([record], shouldCreateSnapshot: shouldCreateSnapshot)
  }

  public mutating func delete(_ record: PersonalDataRecord) throws {
    try delete([record])
  }

  public mutating func delete(with id: Identifier) throws {
    try delete(with: [id])
  }

  public mutating func delete(_ records: [PersonalDataRecord]) throws {
    try delete(with: records.map(\.id))
  }
}

extension DatabaseWriter {
  public mutating func updateSyncStatus(_ status: RecordMetadata.SyncStatus?, for ids: [Identifier])
    throws
  {
    for id in ids {
      guard var metadata = try fetchOneMetadata(with: id) else {
        continue
      }
      metadata.syncStatus = status
      try update(metadata)
    }
  }
}
