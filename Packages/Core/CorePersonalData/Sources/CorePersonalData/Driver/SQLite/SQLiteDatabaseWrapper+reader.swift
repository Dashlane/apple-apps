import Combine
import DashTypes
import Foundation
import GRDB

extension SQLiteDatabaseWrapper: DatabaseReader {
  public func fetchOne(with id: Identifier) throws -> PersonalDataRecord? {
    try RawRecord
      .fetchOne(db, id: id)
      .map(coder.decode)
  }

  public func fetchOneSnapshot(with id: Identifier) throws -> PersonalDataSnapshot? {
    try RawSnapshot
      .fetchOne(db, id: id)
      .map(coder.decode)
  }

  public func fetchOne(withSharingId id: String) throws -> PersonalDataRecord? {
    try RawRecord
      .filter(MetadataColumns.pendingSharingUploadId == id)
      .fetchOne(db)
      .map(coder.decode)
  }

  public func fetchOne(withParentId id: Identifier) throws -> PersonalDataRecord? {
    try RawRecord
      .filter(MetadataColumns.parentId == id)
      .fetchOne(db)
      .map(coder.decode)
  }

  func fetchOneMetadata(with id: Identifier) throws -> RecordMetadata? {
    try RecordMetadata
      .fetchOne(db, id: id)
  }

  func fetchOneMetadata(withSyncRequestId id: String) throws -> RecordMetadata? {
    try RecordMetadata
      .filter(MetadataColumns.syncRequestId == id)
      .fetchOne(db)
  }

  public func fetchAllMetadata() throws -> [RecordMetadata] {
    try RecordMetadata.fetchAll(db)
  }

  public func fetchAllMetadata(with ids: [Identifier]) throws -> [RecordMetadata] {
    try RecordMetadata
      .fetchAll(db, ids: ids)
  }

  public func fetchAll(with ids: [Identifier]) throws -> [PersonalDataRecord] {
    try RawRecord
      .fetchAll(db, ids: ids)
      .map(coder.decode)
  }

  func fetchAllSnapshots(with ids: [Identifier]) throws -> [PersonalDataSnapshot] {
    try RawSnapshot
      .fetchAll(db, ids: ids)
      .map(coder.decode)
  }

  public func fetchAll(by type: PersonalDataContentType) throws -> [PersonalDataRecord] {
    try RawRecord
      .filter(MetadataColumns.contentType == type.rawValue)
      .fetchAll(db)
      .map(coder.decode)
  }

  public func fetchAll(by status: RecordMetadata.SyncStatus) throws -> [PersonalDataRecord] {
    try RawRecord
      .filter(MetadataColumns.syncStatus == status.rawValue)
      .fetchAll(db)
      .map(coder.decode)
  }

  public func fetchAllPendingSharingUpload() throws -> [PersonalDataRecord] {
    try RawRecord
      .filter(MetadataColumns.pendingSharingUploadId != nil)
      .fetchAll(db)
      .map(coder.decode)
  }

  public func count(for kind: PersonalDataContentType) throws -> Int {
    try RawRecord
      .filter(MetadataColumns.contentType == kind.rawValue)
      .fetchCount(db)
  }
}
