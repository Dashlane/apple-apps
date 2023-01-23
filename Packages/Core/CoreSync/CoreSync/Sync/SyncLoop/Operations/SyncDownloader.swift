import Foundation
import DashTypes

struct SyncDownloader {
    
    let service: GetLatestDataService
    let logger: Logger
    
    public init(apiClient: DeprecatedCustomAPIClient, logger: Logger) {
        self.service = GetLatestDataService(apiClient: apiClient)
        self.logger = logger
    }
    
    func callAsFunction(from lastSyncTimestamp: Timestamp,
                        needsKeys: Bool,
                        missingTransactions: [Identifier],
                        report: inout SyncReport) async throws -> DownloadedTransactions {
        logger.info("Download latest (\(missingTransactions.count) missingTransaction(s))")
        logger.debug("missingTransactions: \(missingTransactions)")
        
        do {
            let incomingResponse = try await service.latestData(fromTimestamp: lastSyncTimestamp,
                                                                missingTransactions: missingTransactions,
                                                                needsKeys: needsKeys)
            logger.info("Download Success (\(incomingResponse.transactions.count) transactions - hasFullBackup \((incomingResponse.fullBackup?.content?.count ?? 0) > 0  ))")
            logger.debug("transactions: \(incomingResponse.transactions.debugDescription)")
            report.update(with: incomingResponse)
            return incomingResponse
        } catch {
            logger.debug("Download Data Operation Failed: \(error)")
            throw SyncError.downloadLatest(error: error)
        }
    }
}
