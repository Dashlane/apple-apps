import Foundation
import DashTypes

public struct SyncReport {
    public private(set) var duration: TimeInterval = 0
        public private(set) var timestamp: UInt64 = 0
    public private(set) var incomingUpdateCount: Int = 0
    public private(set) var incomingDeleteCount: Int = 0

        public private(set) var outgoingDeleteCount: Int = 0
    public private(set) var outgoingUpdateCount: Int = 0

    public private(set) var missingTransactionCount: Int = 0

        public private(set) var treatProblemSolutions: [SyncSolution] = []
    private let startTime: Date

    init() {
        startTime = Date()
    }
}

extension SyncReport {
    mutating func update(with incomingTransactions: DownloadedTransactions) {
        self.incomingUpdateCount += incomingTransactions.transactions.filter {
            $0.action == .edit
        }.count

        self.incomingDeleteCount += incomingTransactions.transactions.filter {
            $0.action == .remove
        }.count

        self.timestamp = incomingTransactions.timestamp.rawValue
    }

    mutating func update(with uploadTransactionSession: UploadTransactionSession) {
        self.outgoingDeleteCount += uploadTransactionSession.removedSyncRequestIds.count
        self.outgoingUpdateCount += uploadTransactionSession.updatedSyncRequestIds.count
    }

    mutating func update(with treatProblemSolutions: [SyncSolution]) {
        self.treatProblemSolutions += treatProblemSolutions
    }

    mutating func updateDuration() {
        self.duration = abs(startTime.timeIntervalSinceNow)
    }
}
