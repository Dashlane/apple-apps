import CoreTypes
import Foundation

extension InMemoryDatabase: DatabaseReader {
  public func fetchAll(with ids: [Identifier]) throws -> [PersonalDataRecord] {
    return ids.compactMap { store.records[$0] }
  }

  public func fetchAllSnapshots(with ids: [Identifier]) throws -> [PersonalDataSnapshot] {
    return ids.compactMap { store.snapshots[$0] }
  }

  public func fetchAll(by kind: PersonalDataContentType) throws -> [PersonalDataRecord] {
    return store.records.values.filter { $0.metadata.contentType == kind }
  }

  public func fetchAll(by status: RecordMetadata.SyncStatus) throws -> [PersonalDataRecord] {
    return store.records.values.filter { $0.metadata.syncStatus == status }
  }

  public func fetchAllMetadata() throws -> [RecordMetadata] {
    return store.records.values.map(\.metadata)
  }

  public func fetchAllMetadata(with ids: [Identifier]) throws -> [RecordMetadata] {
    return ids.compactMap { store.records[$0]?.metadata }
  }

  public func fetchAllPendingSharingUpload() throws -> [PersonalDataRecord] {
    return store.records.values.filter { $0.metadata.pendingSharingUploadId != nil }
  }

  public func fetchOne(with id: Identifier) throws -> PersonalDataRecord? {
    return store.records[id]
  }

  public func fetchOneSnapshot(with id: Identifier) throws -> PersonalDataSnapshot? {
    return store.snapshots[id]
  }

  public func fetchOne(withSharingId id: String) throws -> PersonalDataRecord? {
    return store.records.first(where: { $0.value.metadata.pendingSharingUploadId == id })?.value
  }

  public func fetchOne(withParentId id: Identifier) throws -> PersonalDataRecord? {
    return store.records.first(where: { $0.value.metadata.parentId == id })?.value
  }

  public func fetchOneMetadata(with id: Identifier) throws -> RecordMetadata? {
    return store.records[id]?.metadata
  }

  public func fetchOneMetadata(withSyncRequestId id: String) throws -> RecordMetadata? {
    return store.records.first(where: { $0.value.metadata.syncRequestId == id })?.value.metadata
  }

  public func count(for kind: PersonalDataContentType) throws -> Int {
    return try fetchAll(by: kind).count
  }
}
