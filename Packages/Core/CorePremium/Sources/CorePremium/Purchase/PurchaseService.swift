import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StoreKit

public actor PurchaseService {
  public typealias PurchaseStream = AsyncThrowingStream<PurchaseStatus, Error>

  let login: Login
  let appAccountToken: UUID

  let userDeviceAPIClient: UserDeviceAPIClient
  let statusProvider: PremiumStatusProvider
  let receiptVerificationService: ReceiptVerificationServiceProtocol

  let logger: Logger

  private var backgroundTransactionsTask: Task<Void, Never>?

  private var purchaseInProgress: Bool = false

  public init(
    login: Login,
    userDeviceAPIClient: UserDeviceAPIClient,
    statusProvider: PremiumStatusProvider,
    receiptVerificationService: ReceiptVerificationServiceProtocol,
    logger: Logger
  ) async throws {
    self.login = login
    self.appAccountToken = try login.appAccountToken()

    self.userDeviceAPIClient = userDeviceAPIClient
    self.statusProvider = statusProvider
    self.receiptVerificationService = receiptVerificationService
    self.logger = logger

    backgroundTransactionsTask = listenForTransactions()
  }

  public init(
    login: Login,
    userDeviceAPIClient: UserDeviceAPIClient,
    statusProvider: PremiumStatusProvider,
    logger: Logger
  ) async throws {
    self.login = login
    self.appAccountToken = try login.appAccountToken()

    self.userDeviceAPIClient = userDeviceAPIClient
    self.statusProvider = statusProvider
    self.receiptVerificationService = ReceiptVerificationService(
      userDeviceAPIClient: userDeviceAPIClient,
      logger: logger,
      receiptHashStore: .inMemory,
      receiptProvider: Bundle.main)
    self.logger = logger

    backgroundTransactionsTask = listenForTransactions()
  }

  deinit {
    backgroundTransactionsTask?.cancel()
  }
}

extension PurchaseService {
  public func fetchPurchasePlans() async throws -> [PurchasePlan] {
    let offers = try await userDeviceAPIClient.payments.getAccessibleStoreOffers(platform: .ios)
    let productIdentifiers = offers.allOffers().compactMap { $0.storeKitProductId }
    let storeKitProducts = Dictionary(values: try await Product.products(for: productIdentifiers))

    return offers.products.flatMap { dashlaneOfferGroup in
      dashlaneOfferGroup.offers.compactMap { offer -> PurchasePlan? in
        guard let storeKitProductIdentifier = offer.storeKitProductId,
          let storeKitProduct = storeKitProducts[storeKitProductIdentifier],

          let subscription = StoreKitSubscription(
            product: storeKitProduct,
            promotionalOfferIdentifier: offer.storeKitPromotionalOfferId)
        else {
          return nil
        }

        let isCurrentSubscription = offer.storeKitProductId == offers.currentSubscription

        return PurchasePlan(
          subscription: subscription,
          offer: offer,
          kind: dashlaneOfferGroup.kind,
          capabilities: dashlaneOfferGroup.capabilities,
          isCurrentSubscription: isCurrentSubscription)
      }
    }
  }

  public func fetchPurchasePlanGroups() async throws -> [PurchasePlan.Kind: PlanTier] {
    try await fetchPurchasePlans().groupedByKind()
  }
}

extension PurchaseService {
  public func purchase(_ plan: PurchasePlan) -> PurchaseStream {
    let stream = AsyncThrowingStream.makeStream(of: PurchaseStatus.self)

    Task {
      do {
        guard !purchaseInProgress else {
          logger.error("A purchase is already started")
          stream.continuation.finish(throwing: PurchaseError.purchaseAlreadyStarted)
          return
        }

        purchaseInProgress = true
        defer {
          purchaseInProgress = false
        }

        logger.info("Start purchase")
        stream.continuation.yield(.purchasing)

        let result =
          if let promotionalOfferId = plan.subscription.promotionalOffer?.id {
            try await purchase(plan, promotionalOfferId: promotionalOfferId)
          } else {
            try await purchase(plan)
          }

        try await handle(result, subscription: plan.subscription, continuation: stream.continuation)

      } catch let error as DashlaneAPI.APIError {
        logger.error("Purchase has failed due to server API error", error: error)
        stream.continuation.finish(throwing: PurchaseError.apiError(error))
      } catch let error as Product.PurchaseError {
        logger.error("Purchase has failed", error: error)
        stream.continuation.finish(throwing: PurchaseError.productPurchaseError(error))
      } catch let error as StoreKitError {
        logger.error("Purchase has failed due to storeKit internal error", error: error)
        stream.continuation.finish(throwing: PurchaseError.storeKitError(error))
      } catch VerificationReceiptError.invalidReceipt {
        logger.error("Purchase has failed due verification invalid receipt")
        stream.continuation.finish(throwing: PurchaseError.invalidReceipt)
      } catch {
        logger.error("Purchase has failed for unknown reason", error: error)
        stream.continuation.finish(throwing: PurchaseError.unknown(error))
      }
    }
    return stream.stream
  }

  private func purchase(_ plan: PurchasePlan, promotionalOfferId: String) async throws
    -> Product.PurchaseResult
  {
    let applicationUsername = appAccountToken.uuidString

    logger.info("Purchase plan \(plan.offer.planName) with discount id: \(promotionalOfferId)")

    let signatureResponse = try await userDeviceAPIClient.premium
      .getAppleSubscriptionOfferSignature(
        appBundleID: .comDashlaneDashlanephonefinal,
        productIdentifier: plan.subscription.id,
        offerIdentifier: promotionalOfferId,
        applicationUsername: applicationUsername)

    guard let nonce = UUID(uuidString: signatureResponse.nonce),
      let signature = Data(base64Encoded: signatureResponse.signature),
      let timestamp = Int(signatureResponse.timestamp)
    else {
      throw PurchaseError.invalidOfferSignature
    }

    let promotionalOffer = Product.PurchaseOption.promotionalOffer(
      offerID: promotionalOfferId,
      keyID: signatureResponse.keyIdentifier,
      nonce: nonce,
      signature: signature,
      timestamp: timestamp)

    return try await plan.subscription.purchase(options: [
      promotionalOffer, .appAccountToken(appAccountToken),
    ])
  }

  private func purchase(_ plan: PurchasePlan) async throws -> Product.PurchaseResult {
    logger.info("Purchase plan \(plan.offer.planName) without discount")
    return try await plan.subscription.purchase(options: [.appAccountToken(appAccountToken)])
  }

  private func handle(
    _ result: Product.PurchaseResult,
    subscription: StoreKitSubscription,
    continuation: AsyncThrowingStream<PurchaseStatus, Error>.Continuation
  ) async throws {
    switch result {
    case let .success(result):
      switch result {
      case let .unverified(transaction, error):
        logger.fatal(
          "Appstore verification failed on transaction \(transaction.id, privacy: .public)",
          error: error)
        throw PurchaseError.storeKitVerificationError(error, transactionId: transaction.id)

      case let .verified(transaction):
        logger.info("Verify on server transaction")
        continuation.yield(.verifyingReceipt)
        try await receiptVerificationService.verifyReceipt(
          linkedTo: transaction,
          subscription: subscription,
          context: .purchasing)

        await transaction.finish()

        logger.info("Update premium status")
        continuation.yield(.updatingPremiumStatus)
        try? await statusProvider.refresh()

        logger.info("The purchase has succeeded")
        continuation.yield(.success)
        continuation.finish()
      }
    case .userCancelled:
      logger.info("Purchase has been cancelled")
      continuation.yield(.cancelled)
      continuation.finish()

    case .pending:
      logger.info("Purchase is pending user action")
      continuation.yield(.deferred)
      continuation.finish()

    @unknown default:
      logger.error("Transaction is in unknown state")
      continuation.finish(throwing: PurchaseError.unknown(nil))
    }
  }
}

extension PurchaseService {
  private func listenForTransactions() -> Task<Void, Never> {
    Task.detached { [weak self] in
      for await result in Transaction.updates {
        guard let self = self else {
          return
        }
        guard await !self.purchaseInProgress,
          self.statusProvider.status.b2bStatus?.statusCode != .inTeam
        else {
          return
        }

        await self.handle(result)
      }
    }
  }

  private func handle(_ result: VerificationResult<Transaction>) async {
    logger.info("Transaction updates, unfinished transaction or change on existing ones")

    switch result {
    case let .unverified(transaction, error):

      logger.fatal(
        "Appstore verification failed on transaction \(transaction.id, privacy: .public)",
        error: error)
      return
    case let .verified(transaction):
      guard !transaction.isUpgraded,
        await Transaction.unfinished.contains(result)
          || transaction.revocationDate != nil
          || transaction.expirationDate?.compare(.now) == .orderedAscending
      else {
        return

      }

      logger.info("Verify transaction \(transaction.id)")
      do {
        try await receiptVerificationService.verifyReceipt(
          linkedTo: transaction,
          subscription: nil,
          context: .transactionUpdates)
        await transaction.finish()
        try? await statusProvider.refresh()
      } catch {
        logger.error("Verify transaction failed on \(transaction.id)", error: error)
      }
    }
  }
}

extension PaymentsAccessibleStoreOffers {
  var storeKitPromotionalOfferId: String? {
    let planParts = planName.components(separatedBy: ".")
    guard planParts.count == 2 else {
      return nil
    }
    return planParts.last
  }

  var storeKitProductId: Product.ID? {
    return planName.components(separatedBy: ".").first
  }
}
