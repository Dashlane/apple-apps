import Foundation
import DashlaneReportKit
import CorePersonalData

struct WebsiteUsageLogger {
    let usageLogService: UsageLogServiceProtocol

        func logVisitWebsite(item: PersonalWebsite) {
        let log = UsageLogCode75GeneralActions(type: "KWPersonalWebsiteIOS",
                                               action: "gotowebsite",
                                               subaction: "fromDetail",
                                               website: item.website)
        usageLogService.post(log)
    }

}
