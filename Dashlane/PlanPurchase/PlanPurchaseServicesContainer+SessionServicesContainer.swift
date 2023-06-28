import Foundation
import PremiumKit

extension SessionServicesContainer {
    func makePlanPurchaseServices() -> PlanPurchaseServicesContainer {
        return PlanPurchaseServicesContainer(manager: premiumService.manager,
                                             apiClient: userDeviceAPIClient,
                                             logger: appServices.rootLogger[.inAppPurchase],
                                             screenLocker: lockService.locker.screenLocker,
                                             activityReporter: activityReporter)
    }
}
