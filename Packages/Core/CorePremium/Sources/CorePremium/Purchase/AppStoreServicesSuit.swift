import DashTypes
import DashlaneAPI
import Foundation

public struct AppStoreServicesSuit: DependenciesContainer {
  public let purchaseService: PurchaseService
  public let productInfoUpdater: ProductInfoUpdater
  public let receiptVerificationService: ReceiptVerificationService

  public init(
    login: Login,
    userDeviceAPIClient: UserDeviceAPIClient,
    statusProvider: PremiumStatusProvider,
    receiptHashStore: ReceiptHashStore,
    logger: Logger
  ) async throws {
    self.receiptVerificationService = ReceiptVerificationService(
      userDeviceAPIClient: userDeviceAPIClient,
      logger: logger,
      receiptHashStore: receiptHashStore)
    self.purchaseService = try await PurchaseService(
      login: login,
      userDeviceAPIClient: userDeviceAPIClient,
      statusProvider: statusProvider,
      receiptVerificationService: receiptVerificationService,
      logger: logger)

    if #available(iOS 16.4, *) {
      self.productInfoUpdater = await ProductInfoUpdater(
        purchaseService: purchaseService,
        statusProvider: statusProvider,
        logger: logger)
    } else {
      self.productInfoUpdater = await ProductInfoUpdater(
        purchaseService: purchaseService,
        statusProvider: statusProvider,
        updateProductOrder: { _ in },
        logger: logger)
    }
  }

}
