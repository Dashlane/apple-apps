import Foundation
import DashTypes
import CoreData

public enum DownloadedDataParserError: Error, Equatable {
    case couldNotParseJSONData
    case invalidData(transactionId: Identifier)
    case couldNotDecryptData(transactionId: Identifier)
    case timeout
}

public enum ValidationError: Error, Equatable {
    case noSettingsTransactionFound
    case invalidSettingsData
    case couldNotDecode
}

public struct IncomingDataResult<Item> {
    public let items: [Item]
    public let removedItemIds: [Identifier]
        public let timestamp: Timestamp?
    let summary: SyncSummary?
        public let errors: [Error]
}

struct DownloadedDataParser<Database: SyncableDatabase> {
    let database: Database
    let logger: Logger
    
    func callAsFunction(_ incomingResponse: DownloadedTransactions) async -> IncomingDataResult<Database.Item> {
        return await withThrowingTaskGroup(of: [Database.Item].self) { group in
                        if let fullBackupContent = incomingResponse.fullBackup?.content,
               let fullBackupTransaction = incomingResponse.fullBackup?.transactions {
                group.addTask(priority: .background) {
                    return try parse(fullBackupTransaction, inContent: fullBackupContent)
                }
                
            }
            
                        let transactions = incomingResponse
                .transactions
                .lazy
                .filter { transaction in
                    guard let type = transaction.type else {
                        return false
                    }
                    return database.acceptedTypes.contains(type)
                }
            
            for transaction in transactions {
                group.addTask(priority: .background) {
                    try parse(transaction).map {[$0]} ?? []
                }
            }
            
            var decodedPersonalData = [Database.Item]()
            var decodingErrors = [Error]()
            
            while let result = await group.nextResult() {
                switch result {
                    case let .failure(error):
                        decodingErrors.append(error)
                    case let .success(producedData):
                        decodedPersonalData.append(contentsOf: producedData)
                }
            }
            
            let removedIds = incomingResponse.transactions.filter { $0.action == .remove }.map { $0.identifier }
            var summary: SyncSummary? = nil
            if let responseSummary = incomingResponse.summary {
                summary = SyncSummary(timestamp: incomingResponse.timestamp, summary: responseSummary)
            }
            
            return IncomingDataResult(items: decodedPersonalData,
                                      removedItemIds: removedIds,
                                      timestamp: incomingResponse.timestamp,
                                      summary: summary,
                                      errors: decodingErrors)
        }
    }
    
    private func parse(_ transactions: [BackupEntry], inContent encryptedBase64Data: String) throws -> [Database.Item] {
        guard let encryptedData = Data(base64Encoded: encryptedBase64Data) else {
            throw DownloadedDataParserError.invalidData(transactionId: "FullBackup")
        }
        
        var timestamps = [Identifier: Timestamp]()
        transactions
            .sorted { $0.backupDate < $1.backupDate } 
            .forEach {
                timestamps[$0.identifier] = $0.backupDate
            }
        
        return try database.parse(fromEncryptedBackupData: encryptedData, timestamps: timestamps)
    }
    
    private func parse(_ transaction: DownloadedTransaction) throws -> Database.Item? {
        guard let type = transaction.type,
              let content = transaction.content,
              transaction.action != .remove && transaction.action != .unknown else {
                  return nil
              }
        
        guard let encryptedData = Data(base64Encoded: content) else {
            throw DownloadedDataParserError.invalidData(transactionId: transaction.identifier)
        }
        
        return try database.parse(fromEncryptedTransactionData: encryptedData,
                                  identifier: transaction.identifier,
                                  type: type,
                                  timestamp: transaction.backupDate)
    }
}
