import Foundation

public protocol SyncableDatabase {
    associatedtype Item
    
        var acceptedTypes: Set<PersonalDataContentType> { get }

        func parse(fromEncryptedTransactionData data: Data,
               identifier: Identifier,
               type: PersonalDataContentType,
               timestamp: Timestamp) throws -> Item?
        func parse(fromEncryptedBackupData data: Data, timestamps: TimestampByIds) throws -> [Item]
        func update(withIncomingItems: [Item], removedItemIds: [Identifier], shouldMerge: Bool) throws
        
        func prepareUploadTransactionsSession() throws -> UploadTransactionSession
        func close(_ session: UploadTransactionSession, with summary: TimestampByIds) throws
    
        func makeLocalDataSummary() throws -> [TimestampIdPair]
    
        func markAsPendingUploadItems(withIds: [Identifier]) throws
    
        func hasAlreadySync() -> Bool
}

public struct UploadTransactionSession {
 
    public struct Transaction {
        public enum Action {
            case upload(content: String)
            case remove
        }
        
        public let id: Identifier
        public let type: PersonalDataContentType
        public let action: Action

        public init(id: Identifier,
                    type: PersonalDataContentType,
                    action: Action) {
            self.id = id
            self.type = type
            self.action = action
        }
    }

    
    public let transactionsToUpload: [Transaction]
        public let removedSyncRequestIds: [String]
        public let updatedSyncRequestIds: [String]
    
    public init(transactionsToUpload: [UploadTransactionSession.Transaction],
                removedSyncIds: [String],
                updatedSyncIds: [String]) {
        self.transactionsToUpload = transactionsToUpload
        self.removedSyncRequestIds = removedSyncIds
        self.updatedSyncRequestIds = updatedSyncIds
    }
}
