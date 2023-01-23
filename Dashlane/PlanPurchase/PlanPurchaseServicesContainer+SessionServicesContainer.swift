import Foundation
import PremiumKit

extension SessionServicesContainer {
    func makePlanPurchaseServices() -> PlanPurchaseServicesContainer {
        return PlanPurchaseServicesContainer(manager: premiumService.manager,
                                             apiClient: userDeviceAPIClient,
                                             premiumStatusLogger: PremiumStatusLogger(premiumLogService: activityReporter.legacyUsage),
                                             logger: appServices.rootLogger[.session],
                                             screenLocker: lockService.locker.screenLocker,
                                             activityReporter: activityReporter)
    }
}
