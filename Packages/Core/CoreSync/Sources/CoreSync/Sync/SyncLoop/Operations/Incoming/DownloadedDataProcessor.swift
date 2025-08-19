import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

struct DownloadedDataProcessor<Database: SyncableDatabase> {
  struct Output {
    var timestamp: Timestamp
    var remoteTransactionsTimestamp: [TimestampIdPair]?
    let errors: [Identifier: Error]
    let sharingData: SharingData?
  }

  let database: Database
  let logger: Logger
  let shouldParallelize: Bool

  var parse: DownloadedDataParser<Database> {
    DownloadedDataParser(database: database, logger: logger, shouldParallelize: shouldParallelize)
  }

  func callAsFunction(
    _ incomingResponse: DownloadedTransactions,
    shouldMerge: Bool,
    report: inout SyncReport
  ) async throws -> Output {
    do {
      let incomingData = await parse(incomingResponse)
      try self.database.update(
        withIncomingItems: incomingData.items,
        removedItemIds: incomingData.removedItemIds,
        shouldMerge: shouldMerge)

      report.update(with: incomingData)

      self.logger.info("\(incomingData.removedItemIds.count) deleted")
      self.logger.info("\(incomingData.items.count) created or updated")

      let timestampsArray = incomingData.summary?.allTimestamps(
        withTypes: self.database.acceptedTypes
      )
      .map(TimestampIdPair.init)

      return Output(
        timestamp: incomingData.timestamp ?? .distantPast,
        remoteTransactionsTimestamp: timestampsArray,
        errors: incomingData.errors,
        sharingData: (
          incomingResponse.sharing2,
          keys: incomingResponse.keys.flatMap(SyncSharingKeys.init)
        )
      )
    } catch {
      self.logger.error("Download Data Failed", error: error)
      throw error
    }
  }
}

extension SyncSharingKeys {
  init(_ userKeys: UserDeviceAPIClient.Sync.GetLatestContent.Response.Keys) {
    self.init(privateKey: userKeys.privateKey, publicKey: userKeys.publicKey)
  }
}

typealias SharingData = (sharingInfo: SharingSummaryInfo, keys: SyncSharingKeys?)
