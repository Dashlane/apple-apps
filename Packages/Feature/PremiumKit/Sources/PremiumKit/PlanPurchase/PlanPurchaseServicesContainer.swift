import CorePremium
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation

public struct PlanPurchaseServicesContainer {
  let purchaseService: PurchaseService
  let userDeviceAPIClient: UserDeviceAPIClient
  let logger: Logger
  let screenLocker: ScreenLocker?
  let activityReporter: ActivityReporterProtocol

  public init(
    purchaseService: PurchaseService, userDeviceAPIClient: UserDeviceAPIClient, logger: Logger,
    screenLocker: ScreenLocker?, activityReporter: ActivityReporterProtocol
  ) {
    self.purchaseService = purchaseService
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger
    self.screenLocker = screenLocker
    self.activityReporter = activityReporter
  }
}

extension PlanPurchaseServicesContainer {
  @MainActor func makePurchaseViewModel() -> PurchaseViewModel {
    return PurchaseViewModel(purchaseService: purchaseService)
  }

  #if canImport(UIKit)
    func makePurchaseProcessViewModel(with plan: PurchasePlan) -> PurchaseProcessViewModel {
      return PurchaseProcessViewModel(
        purchaseService: purchaseService,
        userDeviceAPIClient: userDeviceAPIClient,
        purchasePlan: plan,
        logger: logger
      )
    }
  #endif
}
