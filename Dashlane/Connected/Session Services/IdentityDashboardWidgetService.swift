import Foundation
import Combine
import WidgetKit
import CorePersonalData
import SecurityDashboard
import DashTypes

class IdentityDashboardWidgetService {
    func refresh(withReport report: SecurityDashboard.PasswordHealthReport) {
        let weakItems = report.allCredentialsReport.countsByFilter[.weak]
        let reusedItems = report.allCredentialsReport.countsByFilter[.reused]
        let compromisedItems = report.allCredentialsReport.countsByFilter[.compromised]

        ApplicationGroup.userDefaults.set(report.allCredentialsReport.totalCount, forKey: DashlaneWidgetConstant.credentialCount)
        ApplicationGroup.userDefaults.set(compromisedItems, forKey: DashlaneWidgetConstant.compromisedCount)
        ApplicationGroup.userDefaults.set(reusedItems, forKey: DashlaneWidgetConstant.reusedCount)
        ApplicationGroup.userDefaults.set(weakItems, forKey: DashlaneWidgetConstant.weakCount)
        ApplicationGroup.userDefaults.set(report.score, forKey: DashlaneWidgetConstant.score)
        ApplicationGroup.userDefaults.synchronize()

        WidgetCenter.shared.reloadTimelines(ofKind: DashlaneWidgetConstant.kind)
    }

    static func clear() {
        ApplicationGroup.userDefaults.set(nil, forKey: DashlaneWidgetConstant.credentialCount)
        ApplicationGroup.userDefaults.set(nil, forKey: DashlaneWidgetConstant.compromisedCount)
        ApplicationGroup.userDefaults.set(nil, forKey: DashlaneWidgetConstant.reusedCount)
        ApplicationGroup.userDefaults.set(nil, forKey: DashlaneWidgetConstant.weakCount)
        ApplicationGroup.userDefaults.set(nil, forKey: DashlaneWidgetConstant.score)
        ApplicationGroup.userDefaults.synchronize()

        WidgetCenter.shared.reloadTimelines(ofKind: DashlaneWidgetConstant.kind)
    }
}
