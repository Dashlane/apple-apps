import DashTypes
import DashlaneAPI
import Foundation

struct SyncUploader<Database: SyncableDatabase> {
  struct Output {
    let timestamp: Timestamp
    let remoteTransactionsTimestamp: [TimestampIdPair]?
  }
  typealias UploadTransaction = UserDeviceAPIClient.Sync.UploadContent.Body.TransactionsElement

  let database: Database
  let apiClient: UserDeviceAPIClient.Sync
  let logger: Logger

  init(
    database: Database,
    apiClient: UserDeviceAPIClient,
    logger: Logger
  ) {
    self.database = database
    self.apiClient = apiClient.sync
    self.logger = logger
  }

  func callAsFunction(from timestamp: Timestamp, report: inout SyncReport) async throws -> Output? {
    do {
      let session = try database.prepareUploadTransactionsSession()

      guard !session.transactionsToUpload.isEmpty else {
        logger.info("Nothing to upload")
        return nil
      }

      logger.info("Uploading \(session.transactionsToUpload.count) transactions from \(timestamp)")
      logger.debug("Transactions: \(session.transactionsToUpload.map(\.id))")

      let transactionsToUpload = session.transactionsToUpload.map(UploadTransaction.init)
      let response = try await apiClient.uploadContent(
        timestamp: Int(timestamp.rawValue),
        transactions: transactionsToUpload,
        sharingKeys: nil)

      let timestampSummary = SyncSummary(response)
      let timestamps = timestampSummary.allTimestamps(withTypes: database.acceptedTypes)

      try self.database.close(session, with: timestamps)
      report.update(with: session)

      return Output(
        timestamp: timestampSummary.timestamp,
        remoteTransactionsTimestamp: timestamps.map(TimestampIdPair.init)
      )

    } catch let error as DashlaneAPI.APIError where error.hasSyncCode(.conflictingUpload) {
      logger.error("Conflict Upload")
      throw SyncUploadConflictError(timestamp: timestamp)
    } catch {
      logger.error("Upload failed", error: error)
      throw error
    }
  }
}

struct SyncUploadConflictError: Error {
  let timestamp: Timestamp
}

public typealias UploadTransaction = UserDeviceAPIClient.Sync.UploadContent.Body.TransactionsElement

extension UserDeviceAPIClient.Sync.UploadContent.Body.TransactionsElement {
  public init(_ transaction: UploadTransactionSession.Transaction) {
    switch transaction.action {
    case let .upload(content):
      self.init(
        identifier: transaction.id,
        type: transaction.type,
        action: .backupEdit,
        content: content)
    case .remove:
      self.init(
        identifier: transaction.id,
        type: transaction.type,
        action: .backupRemove,
        content: nil)
    }
  }

  public init(
    identifier: Identifier, type: PersonalDataContentType, action: SyncContentAction,
    content: String?
  ) {
    self.init(
      identifier: identifier.rawValue,
      time: Int(Date().timeIntervalSince1970),
      type: type.rawValue,
      action: action,
      content: content)
  }
}

extension SyncSummary {
  fileprivate init(_ response: UserDeviceAPIClient.Sync.UploadContent.Response) {
    self.init(
      timestamp: Timestamp(response.timestamp),
      summary: response.summary.mapValues { dictionary in
        dictionary.mapValues(Timestamp.init)
      }
    )
  }
}
