import DashTypes
import DashlaneAPI
import Foundation
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
  let shouldTreatProblems: Bool
  let shouldHandleSharingKeys: Bool

  public init(
    database: Database,
    sharingKeysStore: SharingKeysStore,
    apiClient: UserDeviceAPIClient,
    shouldTreatProblems: Bool = true,
    shouldHandleSharingKeys: Bool = true,
    shouldParallelize: Bool = true,
    logger: Logger
  ) {
    self.download = SyncDownloader(apiClient: apiClient, logger: logger)

    self.processDownloadedData = DownloadedDataProcessor(
      database: database,
      logger: logger,
      shouldParallelize: shouldParallelize)
    self.handleSharingKeys = SharingKeysHandler(
      sharingKeysStore: sharingKeysStore,
      apiClient: apiClient,
      logger: logger)
    self.upload = SyncUploader(database: database, apiClient: apiClient, logger: logger)
    self.treatSyncProblems = SyncProblemsTreater(database: database, logger: logger)
    self.logger = logger

    self.sharingKeysStore = sharingKeysStore
    self.shouldTreatProblems = shouldTreatProblems
    self.shouldHandleSharingKeys = shouldHandleSharingKeys
  }

  public func sync(
    from timestamp: Timestamp,
    waitServerUnlock: Bool = false,
    sharingSummary: inout SharingSummaryInfo?
  ) async throws -> SyncOutput {
    guard !isInProgress else {
      throw SyncError.syncAlreadyInProgress
    }

    isInProgress = true
    defer {
      isInProgress = false
    }

    return try await sync(
      from: timestamp,
      waitServerUnlock: waitServerUnlock,
      sharingSummary: &sharingSummary, attempt: 0)
  }

  private func sync(
    from timestamp: Timestamp,
    waitServerUnlock: Bool,
    sharingSummary: inout SharingSummaryInfo?,
    attempt: Int
  ) async throws -> SyncOutput {
    var syncReport = SyncReport()

    do {

      let storeNeedsKeys = await sharingKeysStore.needsKey
      let timestamp = try await performSync(
        from: timestamp,
        transactionIdsToDownload: [],
        needsKeys: storeNeedsKeys && shouldHandleSharingKeys,
        shouldTreatProblems: shouldTreatProblems,
        waitServerUnlock: waitServerUnlock,
        sharingSummary: &sharingSummary,
        report: &syncReport
      )
      syncReport.updateDuration()
      logger.info("Sync did succeed - timestamp: \(timestamp)")
      return SyncOutput(timestamp: timestamp, syncReport: syncReport)
    } catch let error as SyncUploadConflictError where attempt < 5 {
      logger.warning(
        "Another client uploaded transactions before we managed to upload, re-run the sync")
      return try await sync(
        from: error.timestamp,
        waitServerUnlock: true,
        sharingSummary: &sharingSummary,
        attempt: attempt + 1)
    } catch let error as DashlaneAPI.APIError
      where error.hasSyncCode(.deviceNotFound) || error.hasInvalidRequestCode(.unknownUserdeviceKey)
    {
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

  func waitServerToUnlock() async throws {
    logger.info("Wait server to unlock")
    try await Task.sleep(for: .milliseconds(1100))
  }

  internal func performSync(
    from timestamp: Timestamp,
    transactionIdsToDownload: [Identifier] = [],
    needsKeys: Bool = false,
    shouldTreatProblems: Bool = true,
    waitServerUnlock: Bool,
    sharingSummary: inout SharingSummaryInfo?,
    report: inout SyncReport
  ) async throws -> Timestamp {
    logger.info(
      "Starting sync from timestamp \(timestamp) - shouldTreatProblems \(shouldTreatProblems)")

    if waitServerUnlock {
      try await waitServerToUnlock()
    }

    let transactions = try await download(
      from: timestamp,
      needsKeys: needsKeys,
      missingTransactions: transactionIdsToDownload,
      report: &report)

    let isInitialLoad = timestamp == 0
    if isInitialLoad {
      try await waitServerToUnlock()
    }
    var output = try await processDownloadedData(
      transactions, shouldMerge: !isInitialLoad, report: &report)

    if let summary = output.sharingData?.sharingInfo {
      sharingSummary = summary
    }

    if needsKeys,
      let sharingData = output.sharingData,
      let timestamp = await handleSharingKeys(for: sharingData, syncTimestamp: output.timestamp)
    {
      output.timestamp = timestamp
    }

    if let uploadOutput = try await upload(from: output.timestamp, report: &report) {
      output.timestamp = uploadOutput.timestamp
      if let timestamp = uploadOutput.remoteTransactionsTimestamp {
        output.remoteTransactionsTimestamp = timestamp
      }
    }

    if let remoteDataSummary = output.remoteTransactionsTimestamp, self.shouldTreatProblems {
      previousProblems.formUnion(
        output.errors.map {
          SyncProblem.objectMissingLocally(itemIdentifier: $0.key)
        })

      let problems = try treatSyncProblems(
        forRemoteSummary: remoteDataSummary,
        problems: &previousProblems,
        report: &report)

      if shouldTreatProblems,
        !problems.locallyMissingTransactions.isEmpty
          || !problems.remotelyMissingTransactions.isEmpty
      {

        logger.error("Treating problems, starting a second sync")
        let timestamp = max(output.timestamp, timestamp)
        return try await performSync(
          from: max(output.timestamp, timestamp),
          transactionIdsToDownload: problems.locallyMissingTransactions,
          shouldTreatProblems: false,
          waitServerUnlock: true,
          sharingSummary: &sharingSummary,
          report: &report)
      }
    }

    return output.timestamp
  }
}

extension URLError {
  fileprivate var isNetworkIssue: Bool {
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
