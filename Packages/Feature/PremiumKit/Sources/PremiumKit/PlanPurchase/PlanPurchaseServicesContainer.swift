import CoreFeature
import CorePremium
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import UserTrackingFoundation

public struct PlanPurchaseServicesContainer {
  let purchaseService: PurchaseService
  let userDeviceAPIClient: UserDeviceAPIClient
  let logger: Logger
  let screenLocker: ScreenLocker?
  let activityReporter: ActivityReporterProtocol
  let vaultStateService: VaultStateServiceProtocol?
  let deeplinkingService: PremiumKitDeepLinkingServiceProtocol
  let premiumStatusProvider: PremiumStatusProvider

  public init(
    purchaseService: PurchaseService,
    userDeviceAPIClient: UserDeviceAPIClient,
    logger: Logger, screenLocker: ScreenLocker?,
    activityReporter: ActivityReporterProtocol,
    vaultStateService: VaultStateServiceProtocol?,
    deeplinkingService: PremiumKitDeepLinkingServiceProtocol,
    premiumStatusProvider: PremiumStatusProvider
  ) {
    self.purchaseService = purchaseService
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger
    self.screenLocker = screenLocker
    self.activityReporter = activityReporter
    self.vaultStateService = vaultStateService
    self.deeplinkingService = deeplinkingService
    self.premiumStatusProvider = premiumStatusProvider
  }
}

extension PlanPurchaseServicesContainer {
  @MainActor func makePurchaseViewModel() -> PurchaseViewModel {
    return PurchaseViewModel(purchaseService: purchaseService)
  }

  func makePurchaseProcessViewModel(with plan: PurchasePlan) -> PurchaseProcessViewModel {
    return PurchaseProcessViewModel(
      purchaseService: purchaseService,
      userDeviceAPIClient: userDeviceAPIClient,
      purchasePlan: plan,
      logger: logger
    )
  }
}
