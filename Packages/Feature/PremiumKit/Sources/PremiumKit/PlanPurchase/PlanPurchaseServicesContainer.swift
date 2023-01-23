import Foundation
import CorePremium
import DashTypes
import CoreUserTracking

public struct PlanPurchaseServicesContainer {
    let manager: DashlanePremiumManager
    let apiClient: DeprecatedCustomAPIClient
    let premiumStatusLogger: PremiumStatusLogger
    let logger: Logger
    let screenLocker: ScreenLocker?
    let activityReporter: ActivityReporterProtocol

    public init(manager: DashlanePremiumManager, apiClient: DeprecatedCustomAPIClient, premiumStatusLogger: PremiumStatusLogger, logger: Logger, screenLocker: ScreenLocker?, activityReporter: ActivityReporterProtocol) {
        self.manager = manager
        self.apiClient = apiClient
        self.premiumStatusLogger = premiumStatusLogger
        self.logger = logger
        self.screenLocker = screenLocker
        self.activityReporter = activityReporter
    }
}

extension PlanPurchaseServicesContainer {
    func makePurchaseViewModel() -> PurchaseViewModel {
        return PurchaseViewModel(manager: DashlanePremiumManager.shared, logger: premiumStatusLogger)
    }

    #if canImport(UIKit)
    func makePurchaseProcessViewModel(with plan: PurchasePlan) -> PurchaseProcessViewModel {
        return PurchaseProcessViewModel(
            manager: manager,
            dashlaneAPI: apiClient,
            logger: .init(selectedItem: plan, logger: logger, premiumStatusLogger: premiumStatusLogger),
            purchasePlan: plan
        )
    }
    #endif
}
