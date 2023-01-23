import Foundation
import DashTypes

extension InMemoryDatabase: DatabaseWriter {
    mutating func update(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws {
        try save(records, shouldCreateSnapshot: shouldCreateSnapshot)
    }
    
    mutating func insert(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws {
       try save(records, shouldCreateSnapshot: shouldCreateSnapshot)
    }
    
    mutating func save(_ records: [PersonalDataRecord], shouldCreateSnapshot: Bool) throws {
        for record in records {
            store.records[record.id] = record
        }
        
        if shouldCreateSnapshot {
            for record in records {
                store.snapshots[record.id] = .init(id: record.id, content: record.content)
            }
        }
        
        changes.formUnion(records.map(DatabaseChange.init))
    }
    
    mutating func insert(_ snapshot: PersonalDataSnapshot) throws {
        store.snapshots[snapshot.id] = snapshot
    }
    
    mutating func update(_ metadata: RecordMetadata) throws {
        guard var record = store.records[metadata.id] else {
            return
        }
        
        record.metadata = metadata
        store.records[record.id] = record
        changes.insert(.init(kind: .metadataUpdated, id: record.id))
    }
    
    mutating func updateMetadata(forSyncRequestId id: String, shouldCreateSnapshot: Bool, using updater: (inout RecordMetadata) -> Void) throws {
        guard var record = try fetchOneMetadata(withSyncRequestId: id) else {
            return
        }
        
        updater(&record)
        changes.insert(.init(kind: .metadataUpdated, id: record.id))
    }
    
    
    mutating func delete(with ids: [Identifier]) throws {
        for id in ids {
            store.records[id] = nil
            store.snapshots[id] = nil
            changes.insert(.init(kind: .deleted, id: id))
        }
    }
    
    mutating func delete(withSyncRequestIds ids: [String]) throws {
        let ids = ids.compactMap {
            try? fetchOneMetadata(withSyncRequestId: $0)?.id
        }
        try delete(with: ids)
    }
    
    mutating func clearPending(withSharingUploadIds sharingIds: [String]) throws {
        for id in store.records.keys {
            if let sharingId = store.records[id]?.metadata.pendingSharingUploadId, sharingIds.contains(sharingId) {
                store.records[id]?.metadata.pendingSharingUploadId = nil
            }
        }
    }
}
