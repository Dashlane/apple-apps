import DashTypes
import Foundation

public struct SyncReport {
  public private(set) var duration: TimeInterval = 0

  public private(set) var timestamp: UInt64 = 0
  public private(set) var incomingUpdateAttemptedCount: Int = 0
  public private(set) var incomingUpdateSuccessfulCount: Int = 0
  public private(set) var incomingDeleteAttemptedCount: Int = 0
  public private(set) var incomingDeleteSuccessfulCount: Int = 0

  public private(set) var outgoingUpdateSuccessfulCount: Int = 0
  public private(set) var outgoingDeleteSuccessfulCount: Int = 0

  public private(set) var attemptedTreatProblemSolutions: [SyncSolution] = []
  private let startTime: Date

  init() {
    startTime = Date()
  }
}

extension SyncReport {
  mutating func update(with incomingTransactions: DownloadedTransactions) {
    self.incomingUpdateAttemptedCount +=
      incomingTransactions.transactions.filter {
        $0.action == .backupEdit
      }.count

    self.incomingDeleteAttemptedCount +=
      incomingTransactions.transactions.filter {
        $0.action == .backupRemove
      }.count

    self.timestamp = UInt64(incomingTransactions.timestamp)
  }

  mutating func update<Item>(with result: IncomingDataResult<Item>) {
    self.incomingUpdateSuccessfulCount += result.items.count
    self.incomingDeleteSuccessfulCount += result.removedItemIds.count
  }

  mutating func update(with uploadTransactionSession: UploadTransactionSession) {
    self.outgoingUpdateSuccessfulCount += uploadTransactionSession.updatedSyncRequestIds.count
    self.outgoingDeleteSuccessfulCount += uploadTransactionSession.removedSyncRequestIds.count
  }

  mutating func update(with treatProblemSolutions: [SyncSolution]) {
    self.attemptedTreatProblemSolutions += treatProblemSolutions
  }

  mutating func updateDuration() {
    self.duration = abs(startTime.timeIntervalSinceNow)
  }
}
