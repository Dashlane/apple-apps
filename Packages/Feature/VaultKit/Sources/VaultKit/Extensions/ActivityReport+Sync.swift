import CoreSync
import CoreUserTracking
import Foundation

extension ActivityReporterProtocol {
  public func reportSuccessfulSync(_ syncReport: SyncReport, trigger: Definition.Trigger) {
    self.report(syncReport.makeUserTrackingSyncEvent(trigger: trigger))
  }
}

extension SyncReport {
  fileprivate func makeUserTrackingSyncEvent(trigger: Definition.Trigger) -> UserEvent.Sync {
    let syncExtent: Definition.Extent =
      if trigger == .initialLogin || trigger == .accountCreation {
        .initial
      } else if outgoingDeleteSuccessfulCount > 0 || outgoingUpdateSuccessfulCount > 0 {
        .full
      } else {
        .light
      }

    let msDuration = Int(duration * 1000)
    let duration = Definition.Duration(
      chronological: msDuration, sharing: 0, sync: msDuration, treatProblem: 0)
    return UserEvent.Sync(
      deduplicates: nil,
      duration: duration,
      error: nil,
      extent: syncExtent,
      fullBackupSize: 0,
      incomingDeleteCount: incomingDeleteAttemptedCount,
      incomingUpdateCount: incomingUpdateAttemptedCount,
      outgoingDeleteCount: outgoingDeleteSuccessfulCount,
      outgoingUpdateCount: outgoingUpdateSuccessfulCount,
      timestamp: Int(timestamp / 1000),
      treatProblem: attemptedTreatProblemSolutions.userTrackingTreatProblemStatus,
      trigger: trigger)
  }
}

extension Array where Element == SyncSolution {

  fileprivate var userTrackingTreatProblemStatus: Definition.TreatProblem {
    let containsUpload = self.contains { $0.isUpload }

    let containsDownload = self.contains { $0.isDownload }

    switch (containsUpload, containsDownload) {
    case (true, true):
      return .uploadAndDownload
    case (true, false):
      return .upload
    case (false, true):
      return .download
    case (false, false):
      return .notNeeded
    }
  }
}
