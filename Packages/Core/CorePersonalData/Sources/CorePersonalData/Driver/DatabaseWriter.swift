import Foundation
import Combine
import DashTypes

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
    mutating func updateMetadata(forSyncRequestId: String, shouldCreateSnapshot: Bool, using updater: (inout RecordMetadata) -> Void) throws
    mutating func delete(_ record: PersonalDataRecord) throws
    mutating func delete(with id: Identifier) throws
    mutating func insert(_ snapshot: PersonalDataSnapshot) throws
}

public extension DatabaseWriter {
    mutating func save(_ records: [PersonalDataRecord]) throws {
        try save(records, shouldCreateSnapshot: false)
    }
    
    mutating func insert(_ records: [PersonalDataRecord]) throws {
        try insert(records, shouldCreateSnapshot: false)
    }
    
    mutating func update(_ records: [PersonalDataRecord]) throws {
        try update(records, shouldCreateSnapshot: false)
    }
    
    mutating func save(_ record: PersonalDataRecord) throws {
        try save(record, shouldCreateSnapshot: false)
    }
    
    mutating func insert(_ record: PersonalDataRecord) throws {
        try insert(record, shouldCreateSnapshot: false)
    }
    
    mutating func update(_ record: PersonalDataRecord) throws {
        try update(record, shouldCreateSnapshot: false)
    }
}
    
public extension DatabaseWriter {
    mutating func save(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws {
        try save([record], shouldCreateSnapshot: shouldCreateSnapshot)
    }
    
    mutating func insert(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws {
        try insert([record], shouldCreateSnapshot: shouldCreateSnapshot)
    }
    
    mutating func update(_ record: PersonalDataRecord, shouldCreateSnapshot: Bool) throws {
        try update([record], shouldCreateSnapshot: shouldCreateSnapshot)
    }
    
    mutating func delete(_ record: PersonalDataRecord) throws {
        try delete([record])
    }
    
    mutating func delete(with id: Identifier) throws {
        try delete(with: [id])
    }
    
    mutating func delete(_ records: [PersonalDataRecord]) throws {
        try delete(with: records.map(\.id))
    }
}

extension DatabaseWriter {
    mutating func updateSyncStatus(_ status: RecordMetadata.SyncStatus?, for ids: [Identifier]) throws {
        for id in ids {
            guard var metadata = try fetchOneMetadata(with: id) else {
                continue
            }
            metadata.syncStatus = status
            try update(metadata)
        }
    }
}
