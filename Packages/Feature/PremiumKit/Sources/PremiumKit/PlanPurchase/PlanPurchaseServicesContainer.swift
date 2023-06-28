import Foundation
import CorePremium
import DashTypes
import CoreUserTracking

public struct PlanPurchaseServicesContainer {
    let manager: DashlanePremiumManager
    let apiClient: DeprecatedCustomAPIClient
    let logger: Logger
    let screenLocker: ScreenLocker?
    let activityReporter: ActivityReporterProtocol

    public init(manager: DashlanePremiumManager, apiClient: DeprecatedCustomAPIClient, logger: Logger, screenLocker: ScreenLocker?, activityReporter: ActivityReporterProtocol) {
        self.manager = manager
        self.apiClient = apiClient
        self.logger = logger
        self.screenLocker = screenLocker
        self.activityReporter = activityReporter
    }
}

extension PlanPurchaseServicesContainer {
    func makePurchaseViewModel() -> PurchaseViewModel {
        return PurchaseViewModel(manager: DashlanePremiumManager.shared)
    }

    #if canImport(UIKit)
    func makePurchaseProcessViewModel(with plan: PurchasePlan) -> PurchaseProcessViewModel {
        return PurchaseProcessViewModel(
            manager: manager,
            dashlaneAPI: apiClient,
            purchasePlan: plan,
            logger: logger
        )
    }
    #endif
}
