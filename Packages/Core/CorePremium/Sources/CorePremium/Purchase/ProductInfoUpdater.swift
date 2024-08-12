import Combine
import DashTypes
import DashlaneAPI
import Foundation
import StoreKit

@MainActor
public class ProductInfoUpdater {
  public typealias UpdateProductAction = (_ offerIds: [String]) async throws -> Void
  let purchaseService: PurchaseService
  let statusProvider: PremiumStatusProvider
  let logger: Logger

  private var refreshOnStatusChangeTask: Task<Void, Never>?

  @Published
  public private(set) var hasDiscountAvailable: Bool = false

  let didUpdate = PassthroughSubject<Void, Never>()

  init(
    purchaseService: PurchaseService,
    statusProvider: PremiumStatusProvider,
    updateProductOrder: @escaping UpdateProductAction,
    logger: Logger
  ) {
    self.purchaseService = purchaseService
    self.statusProvider = statusProvider
    self.logger = logger

    refreshOnStatusChangeTask = Task { [weak self] in
      if #available(iOS 16.4, *) {
        for await status in statusProvider.statusPublisher.values {
          guard let self = self else {
            return
          }

          await self.updateProductVisiblityAndHasDiscountState(from: status)
        }
      }
    }
  }

  @available(iOS 16.4, *)
  public convenience init(
    purchaseService: PurchaseService,
    statusProvider: PremiumStatusProvider,
    logger: Logger
  ) {
    self.init(
      purchaseService: purchaseService,
      statusProvider: statusProvider,
      updateProductOrder: Product.PromotionInfo.updateProductOrder,
      logger: logger)
  }

  deinit {
    refreshOnStatusChangeTask?.cancel()
  }

  @available(iOS 16.4, *)
  func updateProductVisiblityAndHasDiscountState(from status: Status) async {
    do {
      defer {
        didUpdate.send()
      }

      guard status.b2bStatus?.statusCode != .inTeam else {
        hasDiscountAvailable = false
        return try await Product.PromotionInfo.updateProductOrder(byID: [])
      }

      let plans = try await purchaseService.fetchPurchasePlans()
      hasDiscountAvailable = plans.contains { $0.isDiscountedOffer }

      logWhenAppStoreDashlanePromoMismatch(plans)

      let productIdentifiers = plans.compactMap { $0.subscription.id }
      return try await Product.PromotionInfo.updateProductOrder(byID: productIdentifiers)
    } catch {
      logger.error("Fail to update product visiblity", error: error)
    }
  }

  func logWhenAppStoreDashlanePromoMismatch(_ plans: [PurchasePlan]) {
    for plan in plans where plan.appStoreDashlanePromoMismatch {
      guard let promotionalOfferId = plan.offer.storeKitPromotionalOfferId else {
        return
      }

      logger.fatal(
        "The promotion \(promotionalOfferId) is not set on AppStore product \(plan.subscription.id)"
      )
    }
  }
}

extension ProductInfoUpdater {
  public static func mock(_ status: Status = .Mock.free, hasDiscount: Bool = false) async throws
    -> ProductInfoUpdater
  {
    let purchaseService = try await PurchaseService(
      login: .init("_"),
      userDeviceAPIClient: .fake,
      statusProvider: .mock(status: status),
      logger: .mock)
    let updater = ProductInfoUpdater(
      purchaseService: purchaseService,
      statusProvider: .mock(status: status),
      updateProductOrder: { _ in },
      logger: .mock)
    updater.hasDiscountAvailable = hasDiscount
    return updater
  }
}
