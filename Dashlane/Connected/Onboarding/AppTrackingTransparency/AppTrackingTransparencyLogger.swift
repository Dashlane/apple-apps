import Foundation
import DashlaneReportKit

struct AppTrackingTransparencyLogger {
    enum Event: String {
        case authorizationRequested
        case authorized
        case denied
        case restricted
        case undetermined

        var action: String {
            return self.rawValue
        }
    }

    let usageLogService: UsageLogServiceProtocol

    func log(_ event: Event) {
        let log = UsageLogCode75GeneralActions(type: "app_tracking_transparency",
                                               action: event.action)
        self.usageLogService.post(log)
        self.usageLogService.uploadLogs() 
    }
}

extension AppTrackingTransparencyLogger {

    enum AttributionResult: String {
        case control
        case treatment
        case attributionImpossible
    }

    func reportABTestAttribution(_ attribution: AttributionResult) {
        let log = UsageLogCode132ABTest(experiment_id: "app_tracking_transparency_cc",
                                        version_id: 1,
                                        variant_id: attribution.rawValue)
        self.usageLogService.post(log)
    }
}
