import Foundation
import PremiumKit

extension SessionServicesContainer {
  func makePlanPurchaseServices() -> PlanPurchaseServicesContainer {
    return PlanPurchaseServicesContainer(
      purchaseService: appStoreServicesSuit.purchaseService,
      userDeviceAPIClient: userDeviceAPIClient,
      logger: appServices.rootLogger[.inAppPurchase],
      screenLocker: lockService.locker.screenLocker,
      activityReporter: activityReporter,
      vaultStateService: vaultStateService,
      deeplinkingService: appServices.deepLinkingService,
      premiumStatusProvider: premiumStatusProvider)
  }
}
