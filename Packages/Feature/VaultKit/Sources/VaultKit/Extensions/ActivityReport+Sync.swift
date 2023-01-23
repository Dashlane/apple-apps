import Foundation
import CoreUserTracking
import CoreSync

extension ActivityReporterProtocol {
    public func reportSuccessfulSync(_ syncReport: SyncReport, extent: Definition.Extent, trigger: Definition.Trigger) {
        self.report(syncReport.userTrackingSyncEvent(with: trigger, extent: extent))
    }
}


private extension SyncReport {
    
    func userTrackingSyncEvent(with trigger: Definition.Trigger, extent: Definition.Extent) -> UserEvent.Sync {
        let msDuration = Int(duration * 1000)
        let duration = Definition.Duration(chronological: msDuration, sharing: 0, sync: msDuration, treatProblem: 0)
        return UserEvent.Sync(deduplicates: nil,
                              duration: duration,
                              error: nil,
                              extent: extent,
                              fullBackupSize: fullBackupItemCount,
                              incomingDeleteCount: incomingDeleteCount,
                              incomingUpdateCount: incomingUpdateCount,
                              outgoingDeleteCount: outgoingDeleteCount,
                              outgoingUpdateCount: outgoingUpdateCount,
                              timestamp: Int(timestamp / 1000),
                              treatProblem: treatProblemSolutions.userTrackingTreatProblemStatus,
                              trigger: trigger)
    }
}

private extension Array where Element == SyncSolution {
    
    var userTrackingTreatProblemStatus: Definition.TreatProblem {
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

