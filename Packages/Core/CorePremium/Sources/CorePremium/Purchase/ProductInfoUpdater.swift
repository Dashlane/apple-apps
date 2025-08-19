import Combine
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StoreKit

@MainActor
public class ProductInfoUpdater {
  public typealias UpdateProductAction = (_ offerIds: [String]) async throws -> Void
  let purchaseService: PurchaseService
  let statusProvider: PremiumStatusProvider
  let logger: Logger
  let updateProductOrder: UpdateProductAction

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
    self.updateProductOrder = updateProductOrder
    self.logger = logger

    refreshOnStatusChangeTask = Task { [weak self] in
      for await status in statusProvider.statusPublisher.values {
        guard let self = self else {
          return
        }

        await self.updateProductVisiblityAndHasDiscountState(from: status)
      }
    }
  }

  public convenience init(
    purchaseService: PurchaseService,
    statusProvider: PremiumStatusProvider,
    logger: Logger
  ) {
    #if os(visionOS)
      self.init(
        purchaseService: purchaseService,
        statusProvider: statusProvider,
        updateProductOrder: { _ in },
        logger: logger)
    #else
      self.init(
        purchaseService: purchaseService,
        statusProvider: statusProvider,
        updateProductOrder: Product.PromotionInfo.updateProductOrder,
        logger: logger
      )
    #endif
  }

  deinit {
    refreshOnStatusChangeTask?.cancel()
  }

  func updateProductVisiblityAndHasDiscountState(from status: Status) async {
    do {
      defer {
        didUpdate.send()
      }

      guard status.b2bStatus?.statusCode != .inTeam else {
        hasDiscountAvailable = false
        return try await updateProductOrder([])
      }

      let plans = try await purchaseService.fetchPurchasePlans()
      hasDiscountAvailable = plans.contains { $0.isDiscountedOffer }

      logWhenAppStoreDashlanePromoMismatch(plans)

      let productIdentifiers = plans.compactMap { $0.subscription.id }
      return try await updateProductOrder(productIdentifiers)
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
        "The promotion \(promotionalOfferId, privacy: .public) is not set on AppStore product \(plan.subscription.id, privacy: .public)"
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
