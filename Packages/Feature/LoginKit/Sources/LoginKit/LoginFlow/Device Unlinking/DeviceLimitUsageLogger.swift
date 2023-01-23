import Foundation
import DashlaneReportKit
import CoreSession
import CoreUserTracking

public struct DeviceLimitUsageLogger {
    public enum Screen: String {
        case limitPrompt = "limit_prompt"
        case unlinkScreen = "unlink_screen"
    }

    public enum Action: String {
        case seen
        case seePremium = "see_premium"
        case startUnlink = "unlink_previous"
        case logout
        case unlink
        case cancelUnlink = "cancel_unlink"
        case upgrade
    }

    let logger: LoginUsageLogServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let mode: DeviceUnlinker.UnlinkMode

    public init(logger: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                mode: DeviceUnlinker.UnlinkMode) {
        self.logger = logger
        self.activityReporter = activityReporter
        self.mode = mode
    }

    public func log(_ screen: Screen,
             action: Action,
             numberOfSelectedDevices: Int? = nil) {
        let log = UsageLogCode75GeneralActions(type: mode.logValue,
                                               subtype: screen.rawValue,
                                               action: action.rawValue,
                                               subaction: numberOfSelectedDevices.map { String($0) })
        logger.post(log, completion: nil)

        switch mode {
        case .multiple:
            activityReporter.reportPageShown(.paywallDeviceSyncLimit)
        default:
            break
        }
    }
}

private extension DeviceUnlinker.UnlinkMode {
    var logValue: String {
        switch self {
            case .monobucket:
                return "monobucket"
            case .multiple:
                return "device_sync_limit"
        }
    }
}
