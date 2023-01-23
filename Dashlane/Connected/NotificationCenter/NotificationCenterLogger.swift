import Foundation
import DashlaneReportKit

struct NotificationCenterLogger {

    let type = "action_items"

    let homepageAction = "homepage"

    enum SubAction: String {
        case show
        case click
        case dismiss
        case undo
    }

    enum Action: String {
        case test
        case control
    }

    let usageLogService: UsageLogServiceProtocol

    func logActionItemCenterAppearance() {
        let log = UsageLogCode75GeneralActions.init(type: type,
                                                    subtype: nil,
                                                    action: homepageAction,
                                                    subaction: SubAction.show.rawValue)
        usageLogService.post(log)
    }

    func log(subaction: SubAction, for notificationPrefix: String) {
        let log = UsageLogCode75GeneralActions.init(type: type,
                                                    subtype: "announcement",
                                                    action: notificationPrefix,
                                                    subaction: subaction.rawValue)
        usageLogService.post(log)
    }
}
