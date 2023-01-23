import Foundation
import DashTypes
import SwiftUI
import Combine

public class SharingPersonalDataDBStack {
    let driver: DatabaseDriver
    let logger: Logger
    let parser = PersonalDataXMLParser()
    let cryptoEngine = PersonalDataXMLParser()
    let historyUpdater: HistoryUpdater
    let decoder: PersonalDataDecoder
    
    @Published
    var pendingActivationRecords: [Identifier: PersonalDataRecord] = [:]
    
    public init(driver: DatabaseDriver,
                codeDecoder: CodeDecoder?,
                personalDataURLDecoder: PersonalDataURLDecoder?,
                historyUserInfo: HistoryUserInfo,
                logger: Logger) {
        self.driver = driver
        self.historyUpdater = HistoryUpdater(info: historyUserInfo)
        self.logger = logger
        self.decoder = PersonalDataDecoder(codeDecoder: codeDecoder, personalDataURLDecoder: personalDataURLDecoder)
    }
}

extension SharingPersonalDataDBStack: SharingPersonalDataDB {
    public func sharedItemIds() async throws -> [DashTypes.Identifier] {
        try driver.read { db in
            try db.fetchAllMetadata().filter { $0.isShared }.map(\.id)
        }
    }
    
        public func perform(_ updates: [DashTypes.SharingItemUpdate]) async throws {
        try driver.write { db in
            for update in updates {
                try perform(update, in: &db)
            }
        }
    }

    private func perform(_ update: SharingItemUpdate, in db: inout DatabaseWriter) throws {
                if let content = update.transactionContent {
           try performFullUpdate(update, content: content, in: &db)
        }
                else {
           try performSharingStateUpdateOnly(update, in: &db)
        }
    }
    
    private func performFullUpdate(_ update: SharingItemUpdate, content: Data, in db: inout DatabaseWriter) throws {
        guard let record = makeRecord(id: update.id, state: update.state, content: content) else {
            return
        }
        
        if update.state.isAccepted {
            pendingActivationRecords[update.id] = nil

            if let existingRecord = try db.fetchOneForSharing(with: record.id) {
                var updatedRecord = existingRecord
                if updatedRecord.mergeSharedContent(record.content) {
                    updatedRecord.metadata.markAsPendingUpload()
                }
                updatedRecord.metadata.apply(update.state)
                try db.update(updatedRecord)
                try? historyUpdater.updateIfNeeded(forNewRecord: updatedRecord,
                                                   previousRecord: existingRecord,
                                                   in: &db)
            } else {
                try db.insert(record)
            }
        } else {
            pendingActivationRecords[update.id] = record
        }
    }
    
    private func performSharingStateUpdateOnly(_ update: SharingItemUpdate, in db: inout DatabaseWriter) throws {
        if update.state.isAccepted {
                        if var existingRecord = try db.fetchOneForSharing(with: update.id) {
                existingRecord.metadata.apply(update.state)
                try db.update(existingRecord)
            }
                        else if var pendingRecord = pendingActivationRecords[update.id] {
                pendingRecord.metadata.apply(update.state)
                try db.insert(pendingRecord)
                pendingActivationRecords[update.id] = nil
            } else {
                logger.fatal("Should not receive an update on an unknown item")
            }
        }
                else if var pendingRecord = pendingActivationRecords[update.id] {
            pendingRecord.metadata.sharingPermission = update.state.permission
            pendingActivationRecords[update.id] = pendingRecord
        }
        else {
            logger.fatal("Should not receive an update on an unknown pending item")
        }
    }
    
    
    private func makeRecord(id: Identifier,
                            state: SharingItemUpdate.State,
                            content: Data) -> PersonalDataRecord? {
        do {
            var record = try PersonalDataRecord(id: id, compressedXMLData: content)
            record.metadata.markAsPendingUpload()
            record.metadata.apply(state)

            return record
        } catch {
            logger.fatal("Cannot create record from sharing item summary", error: error)
            return nil
        }
    }
    
        private func pendingOrInDBRecord(for id: Identifier) throws -> PersonalDataRecord? {
        if let record = pendingActivationRecords[id] {
            return record
        } else {
            return try driver.read { db in
                try db.fetchOneForSharing(with: id)
            }
        }
    }
    
   
        public func delete(with ids: [Identifier]) async throws {
        guard !ids.isEmpty else {
            return
        }
        
        try driver.write { db in
            let records = try db.fetchAll(with: ids)
            
            for var record in records {
                record.metadata.syncStatus = .pendingRemove
                record.metadata.pendingSharingUploadId = nil
                record.metadata.isShared = false
                try db.update(record)
                try historyUpdater.updateIfNeeded(forDeletedRecord: record, in: &db)
            }
        }
        
        for id in ids {
            pendingActivationRecords.removeValue(forKey: id)
        }
    }
    
    public func reCreateAcceptedItem(with id: Identifier) async throws {
        try driver.write { db in
            guard var record = try db.fetchOneForSharing(with: id) else {
                return
            }
            
            record.metadata.markAsPendingRemove()
            record.metadata.pendingSharingUploadId = nil
            record.metadata.isShared = false

            try db.update(record)
            
            record.metadata.id = Identifier()
            record[.id] = record.metadata.id.rawValue
            record.metadata.markAsPendingUpload()
            try db.insert(record)
       }
    }
    
    
        public func pendingUploads() async throws -> [SharingItemUpload] {
        let records = try driver.read { db in
             try db.fetchAllPendingSharingUpload()
        }
        
        return try await withThrowingTaskGroup(of: SharingItemUpload.self) { group in
            for record in records {
                guard let uploadId = record.metadata.pendingSharingUploadId, record.metadata.syncStatus != .pendingRemove else {
                    continue
                }
                
                group.addTask {
                    .init(id: record.id,
                          uploadId: uploadId,
                          transactionContent: try record.compressedXMLData())
                }
            }
            
            return try await group.reduce(into: []) { uploads, upload in
                uploads.append(upload)
            }
        }
    }

    public func clearPendingUploads(withIds ids:  [String]) async throws {
        try driver.write { db in
            try db.clearPending(withSharingUploadIds: ids)
        }
    }
    
    public func metadata(for ids: [Identifier]) async throws -> [SharingMetadata] {
        var idsToFetchInDB: [Identifier] = []
        var pendingMetadata: [SharingMetadata] = []

        for id in ids {
            if let metadata = pendingActivationRecords[id]?.makeSharingMetadata() {
                pendingMetadata.append(metadata)
            } else {
                idsToFetchInDB.append(id)
            }
        }
        
        guard !idsToFetchInDB.isEmpty else {
            return pendingMetadata
        }
        
        let metadataInDB = try driver.read { db in
            try db.fetchAll(with: idsToFetchInDB)
                .filter { $0.metadata.syncStatus != .pendingRemove }
                .compactMap { $0.makeSharingMetadata() }
        }
        
        return pendingMetadata + metadataInDB
    }
    
    public func createSharingContents(for ids: [Identifier]) async throws -> [SharingCreateContent] {
        return try driver.read { db in
            try db.fetchAll(with: ids)
                .filter { $0.metadata.syncStatus != .pendingRemove }
                .compactMap { try $0.makeCreateSharingContent() }
        }
    }
    
                        public func spaceId(for id: Identifier) throws -> String {
        return try pendingOrInDBRecord(for: id)?[.spaceId] ?? ""
    }
}

extension SharingPersonalDataDBStack {
        public func pendingItemsPublisher() -> AnyPublisher<[Identifier: PersonalDataCodable], Never> {
        $pendingActivationRecords.map { records in
            return records.compactMapValues { [weak self] record in
                guard let sharingType = record.metadata.contentType.sharingType, let self = self else {
                    return nil
                }
                
                return try? self.decoder.decode(sharingType, from: record, using: LinkedFetcherImpl(driver: self.driver))
            }
        }.eraseToAnyPublisher()
    }
    
    public func update(spaceId: String, toPendingItemWithId id: Identifier) {
        pendingActivationRecords[id]?[.spaceId] = spaceId
    }
}


fileprivate extension RecordMetadata {
    mutating func apply(_ state: SharingItemUpdate.State) {
       isShared = true 
       sharingPermission = state.permission
    }
}

fileprivate extension PersonalDataRecord {
    func makeSharingMetadata() -> SharingMetadata? {
        guard let type = metadata.contentType.sharingType else {
            return nil
        }
        return SharingMetadata(title: self[.title] ?? "", type: type)
    }
    
    func makeCreateSharingContent() throws -> SharingCreateContent? {
        guard let metadata = makeSharingMetadata() else {
            return nil
        }
        let content = try compressedXMLData()
        
        return SharingCreateContent(id: id,
                                    metadata: metadata,
                                    transactionContent: content)
    }
}
