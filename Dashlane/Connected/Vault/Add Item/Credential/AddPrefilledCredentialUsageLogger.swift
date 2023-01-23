import Foundation
import DashlaneReportKit

struct AddPrefilledCredentialUsageLogger {
    let usageLogService: UsageLogServiceProtocol

    func selectedWebsiteUsageLog(website: String?) {
        guard let website = website else { return }
        usageLogService.post(UsageLogCode75GeneralActions(type: "pwd_add", action: "selectWebsite", website: website))
    }

}
