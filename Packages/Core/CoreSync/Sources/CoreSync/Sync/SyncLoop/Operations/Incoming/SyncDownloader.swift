import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

struct SyncDownloader {
  let apiClient: UserDeviceAPIClient.Sync
  let logger: Logger

  public init(apiClient: UserDeviceAPIClient, logger: Logger) {
    self.apiClient = apiClient.sync
    self.logger = logger
  }

  func callAsFunction(
    from lastSyncTimestamp: Timestamp,
    needsKeys: Bool,
    missingTransactions: [Identifier],
    report: inout SyncReport
  ) async throws -> DownloadedTransactions {
    if missingTransactions.isEmpty {
      logger.info("Download latest")
    } else {
      logger.info("Download latest with \(missingTransactions.count) missingTransaction(s)")
      logger.debug("missingTransactions: \(missingTransactions.debugDescription)")
    }

    do {
      let incomingResponse = try await apiClient.getLatestContent(
        timestamp: Int(lastSyncTimestamp.rawValue),
        transactions: missingTransactions.map(\.rawValue),
        needsKeys: needsKeys,
        teamAdminGroups: false)

      logger.info("Download Success (\(incomingResponse.transactions.count) transactions)")
      logger.debug("Downloaded transactions: \(incomingResponse.transactions.map(\.identifier))")
      report.update(with: incomingResponse)

      return incomingResponse
    } catch {
      logger.error("Download Data Operation Failed: \(error)")
      throw error
    }
  }
}
