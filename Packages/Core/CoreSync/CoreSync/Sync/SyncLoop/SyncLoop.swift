import Foundation
import DashTypes
import SwiftTreats

public enum SyncError: Swift.Error {
    case unknownUserDevice
    case offline
    case sync(Error)
    case syncAlreadyInProgress
}

public actor SyncLoop<Database: SyncableDatabase> {
            var previousProblems: Set<SyncProblem> = []
    var isInProgress = false
    var sharingKeysStore: SharingKeysStore

    let download: SyncDownloader
    let handleSharingKeys: SharingKeysHandler
    let processDownloadedData: DownloadedDataProcessor<Database>
    let upload: SyncUploader<Database>
    let treatSyncProblems: SyncProblemsTreater<Database>
    let logger: Logger

                                public init(database: Database,
                sharingKeysStore: SharingKeysStore,
                apiClient: DeprecatedCustomAPIClient,
                logger: Logger) {
        self.init(database: database,
                  sharingKeysStore: sharingKeysStore,
                  downloadAPIClient: apiClient,
                  uploadAPIClient: apiClient,
                  logger: logger)
    }

    init(database: Database,
         sharingKeysStore: SharingKeysStore,
         downloadAPIClient: DeprecatedCustomAPIClient,
         uploadAPIClient: DeprecatedCustomAPIClient,
         logger: Logger) {
        self.download = SyncDownloader(apiClient: downloadAPIClient,
                                                  logger: logger)

        self.processDownloadedData = DownloadedDataProcessor(database: database,
                                                             logger: logger)
        self.handleSharingKeys = SharingKeysHandler(sharingKeysStore: sharingKeysStore, apiClient: uploadAPIClient)
        self.upload = SyncUploader(database: database,
                                   apiClient: uploadAPIClient,
                                   logger: logger)

        self.treatSyncProblems = SyncProblemsTreater(database: database,
                                                     logger: logger)
        self.logger = logger

        self.sharingKeysStore = sharingKeysStore
    }

                    public func sync(from timestamp: Timestamp, sharingSummary: inout SharingSummaryInfo?) async throws -> SyncOutput {
        guard !isInProgress else {
            throw SyncError.syncAlreadyInProgress
        }

        isInProgress = true
        defer {
            isInProgress = false
        }

        return try await sync(from: timestamp, sharingSummary: &sharingSummary, attempt: 0)
    }

    private func sync(from timestamp: Timestamp, sharingSummary: inout SharingSummaryInfo?, attempt: Int) async throws -> SyncOutput {
        var syncReport = SyncReport()

        do {
            let timestamp = try await performSync(from: timestamp,
                                                  transactionIdsToDownload: [],
                                                  needsKeys: await sharingKeysStore.needsKey,
                                                  shouldTreatProblems: true,
                                                  sharingSummary: &sharingSummary,
                                                  report: &syncReport)
            syncReport.updateDuration()
            logger.info("Sync did succeed - timestamp: \(timestamp)")
            return SyncOutput(timestamp: timestamp, syncReport: syncReport)
        } catch let error as SyncUploadConflictError where attempt < 5 { 
            logger.warning("Another client uploaded transactions before we managed to upload, re-run the sync")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return try await sync(from: error.timestamp, sharingSummary: &sharingSummary, attempt: attempt + 1)
        } catch let error as APIErrorResponse where error.containsUnknownDeviceError() {
            logger.warning("Device is unknown")
            throw SyncError.unknownUserDevice
        } catch let error as URLError where error.isNetworkIssue {
            logger.warning("Sync is Offline")
            throw SyncError.offline
        } catch {
            logger.fatal("Sync failed", error: error)
            throw SyncError.sync(error)
        }
    }

                                    internal func performSync(from timestamp: Timestamp,
                              transactionIdsToDownload: [Identifier] = [],
                              needsKeys: Bool = false,
                              shouldTreatProblems: Bool = true,
                              sharingSummary: inout SharingSummaryInfo?,
                              report: inout SyncReport) async throws -> Timestamp {
        logger.info("Starting sync from timestamp \(timestamp) - shouldTreatProblems \(shouldTreatProblems)")

        let transactions = try await download(from: timestamp,
                                              needsKeys: needsKeys,
                                              missingTransactions: transactionIdsToDownload,
                                              report: &report)
                let isInitialLoad = timestamp == 0
        var output = try await processDownloadedData(transactions, shouldMerge: !isInitialLoad)

        if let summary = output.sharingData?.sharingInfo {
            sharingSummary = summary
        }

                if let rawSharingKeys = output.sharingData?.keys,
           let timestamp = try await handleSharingKeys(rawSharingKeys, syncTimestamp: output.timestamp) {
            output.timestamp = timestamp
        }

                if let uploadOutput = try await upload(from: output.timestamp, report: &report) {
            output.timestamp = uploadOutput.timestamp
            output.remoteTransactionsTimestamp = uploadOutput.remoteTransactionsTimestamp ?? output.remoteTransactionsTimestamp
        }

                if shouldTreatProblems, let remoteDataSummary = output.remoteTransactionsTimestamp {
            let problems = try treatSyncProblems(forRemoteSummary: remoteDataSummary,
                                                 problems: &previousProblems,
                                                 report: &report)
            if !problems.locallyMissingTransactions.isEmpty {
                logger.error("Missing transactions found, starting a second sync")
                                return try await performSync(from: max(output.timestamp, timestamp),
                                             transactionIdsToDownload: problems.locallyMissingTransactions,
                                             shouldTreatProblems: false,
                                             sharingSummary: &sharingSummary,
                                             report: &report)
            }
        }

        return output.timestamp
    }
}

extension APIErrorResponse {
    func containsUnknownDeviceError() -> Bool {
        return errors.contains(where: { $0.code == "unknown_userdevice_key" })
    }
}

private extension URLError {
    var isNetworkIssue: Bool {
        switch self.code {
            case .badServerResponse,
                 .cancelled,
                 .networkConnectionLost,
                 .notConnectedToInternet,
                 .redirectToNonExistentLocation,
                 .timedOut,
                 .unknown:
                return true
            default:
                return false

        }
    }
}
