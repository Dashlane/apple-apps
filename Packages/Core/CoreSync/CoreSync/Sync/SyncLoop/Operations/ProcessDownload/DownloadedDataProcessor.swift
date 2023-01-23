import Foundation
import DashTypes

struct DownloadedDataProcessor<Database: SyncableDatabase> {
    struct Output {
        var timestamp: Timestamp
        var remoteTransactionsTimestamp: [TimestampIdPair]?
        let errors: [Error]?
        let sharingData: SharingData?
    }
    
    let database: Database
    let logger: Logger
    
    var parse: DownloadedDataParser<Database> {
        DownloadedDataParser(database: database, logger: logger)
    }
    
    func callAsFunction(_ incomingResponse: DownloadedTransactions, shouldMerge: Bool) async throws -> Output {
        do {
            let incomingData = await parse(incomingResponse)
            
            try self.database.update(withIncomingItems: incomingData.items,
                                     removedItemIds: incomingData.removedItemIds,
                                     shouldMerge: shouldMerge)
            
            self.logger.info("Processing Success - \(incomingData.removedItemIds.count) deleted - \(incomingData.items.count) created or updated")
            
            let timestampsArray = incomingData.summary?.allTimestamps(withTypes: self.database.acceptedTypes).map(TimestampIdPair.init)
            
            return Output(timestamp: incomingData.timestamp ?? .distantPast,
                          remoteTransactionsTimestamp: timestampsArray,
                          errors: incomingData.errors,
                          sharingData: (incomingResponse.sharingInfo, incomingResponse.keys))
        } catch {
            self.logger.error("Download Data Failed", error: error)
            throw SyncError.downloadLatest(error: error)
        }
    }
}

typealias SharingData = (sharingInfo: SharingSummaryInfo?, keys: RawSharingKeys?)
