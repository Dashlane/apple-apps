import Foundation
import DashlaneReportKit

struct SecureNotesDetailUsageLogger {
    let usageLogService: UsageLogServiceProtocol

    func shareUsageLog() {
        let log = UsageLogCode80SharingUX(type: .newShare1,
                                          action: .open,
                                          from: .secureNotes)
        usageLogService.post(log)
    }

    func lockUsageLog(secured: Bool) {
        let log = UsageLogCode75GeneralActions(type: "KWSecureNote", subtype: "fromDetails", action: secured ? "lock" : "unlock")
        usageLogService.post(log)
    }
}
