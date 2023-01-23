import Foundation
import DashTypes

struct SyncUploader<Database: SyncableDatabase> {
    struct Output {
        let timestamp: Timestamp
        let remoteTransactionsTimestamp: [TimestampIdPair]?
    }
    let database: Database
    let uploadContentService: UploadContentService
    let logger: Logger
    
    init(database: Database,
         apiClient: DeprecatedCustomAPIClient,
         logger: Logger) {
        self.database = database
        self.uploadContentService = UploadContentService(apiClient: apiClient)
        self.logger = logger
    }
    
    func callAsFunction(from timestamp: Timestamp, report: inout SyncReport) async throws -> Output? {
        do {
            let session = try database.prepareUploadTransactionsSession()
            
            guard !session.transactionsToUpload.isEmpty else {
                logger.debug("Nothing to upload")
                return nil
            }
            
            let params = UploadContentParams(timestamp: timestamp, transactions: session.transactionsToUpload.map(UploadTransaction.init))
            let timestampSummary = try await uploadContentService.upload(params)
            let timestamps = timestampSummary.allTimestamps(withTypes: self.database.acceptedTypes)
            try self.database.close(session, with: timestamps)
            report.update(with: session)
            return Output(timestamp: timestampSummary.timestamp,
                          remoteTransactionsTimestamp: timestamps.map(TimestampIdPair.init))
        } catch {
            logger.error("Upload failed", error: error)
            throw SyncError.uploadData(error: error, timestamp: timestamp)
        }
    }
}
