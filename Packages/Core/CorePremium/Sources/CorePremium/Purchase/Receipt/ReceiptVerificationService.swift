import CoreTypes
import CryptoKit
import DashlaneAPI
import Foundation
import LogFoundation
import StoreKit

public protocol ReceiptVerificationServiceProtocol {
  func verifyReceipt(
    linkedTo transaction: Transaction,
    subscription: StoreKitSubscription?,
    context: VerificationReceiptContext) async throws
}

@Loggable
public enum VerificationReceiptError: Error {
  case invalidReceipt
  case noReceiptItemOnServer
  case noReceiptItemOnLocal
  case receiptDidNotChangeLocally
}

@Loggable
public enum VerificationReceiptContext {
  case purchasing
  case postLaunch
  case transactionUpdates

  var retryCountMax: Int {
    switch self {
    case .purchasing:
      return 3
    case .postLaunch, .transactionUpdates:
      return 1
    }
  }
}

public struct ReceiptVerificationService: ReceiptVerificationServiceProtocol {
  static var runInSimulator: Bool = false

  typealias VerifyReceiptRequest = UserDeviceAPIClient.Payments.VerifyApplestoreReceipt.Body
  let userDeviceAPIClient: UserDeviceAPIClient
  let logger: Logger
  let receiptHashStore: ReceiptHashStore
  let receiptProvider: ReceiptProvider

  public init(
    userDeviceAPIClient: UserDeviceAPIClient,
    logger: Logger,
    receiptHashStore: ReceiptHashStore,
    receiptProvider: ReceiptProvider = Bundle.main
  ) {
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger
    self.receiptHashStore = receiptHashStore
    self.receiptProvider = receiptProvider
  }

  public func verifyReceipt(
    linkedTo transaction: Transaction,
    subscription: StoreKitSubscription?,
    context: VerificationReceiptContext
  ) async throws {
    try await perform(using: transaction, subscription: subscription, context: context)
  }

  public func verifyReceiptPostLaunch() async throws {
    do {
      try await perform(context: .postLaunch)
    } catch VerificationReceiptError.receiptDidNotChangeLocally {
      logger.info("Receipt didn't change since last launch.")
    }
  }

  private func perform(
    using transaction: Transaction? = nil,
    subscription: StoreKitSubscription? = nil,
    context: VerificationReceiptContext
  ) async throws {
    try await perform(
      using: transaction,
      subscription: subscription,
      remainingRetry: context.retryCountMax,
      controlIfReceiptChangedLocally: context == .postLaunch,
      context: context)
  }

  private func perform(
    using transaction: Transaction?,
    subscription: StoreKitSubscription?,
    remainingRetry: Int,
    controlIfReceiptChangedLocally: Bool,
    context: VerificationReceiptContext
  ) async throws {
    #if targetEnvironment(simulator)
      guard Self.runInSimulator else {
        return
      }
    #endif

    logger.info("Verifying receipt in context \(context). remainingRetry: \(remainingRetry)")

    let receiptData = try await receiptProvider.receipt()
    let request = VerifyReceiptRequest(
      transaction: transaction,
      subscription: subscription,
      receiptData: receiptData,
      context: context)
    let receiptHash = receiptData.sha256Hash()

    do {
      if controlIfReceiptChangedLocally,
        let storedHash = receiptHashStore.receiptHash(),
        storedHash == receiptHash
      {
        throw VerificationReceiptError.receiptDidNotChangeLocally
      }

      let response = try await userDeviceAPIClient.payments.verifyApplestoreReceipt(request)

      receiptHashStore.storeReceiptHash(receiptHash)

      if !response.success {
        throw VerificationReceiptError.invalidReceipt
      }
    } catch let error as DashlaneAPI.APIError where error.hasPaymentsCode(.invalidReceipt) {
      receiptHashStore.storeReceiptHash(receiptHash)

      try await retry(
        for: .invalidReceipt,
        transaction: transaction,
        subscription: subscription,
        remainingRetry: remainingRetry,
        controlIfReceiptChangedLocally: true,
        context: context)

    } catch let error as DashlaneAPI.APIError where error.hasPaymentsCode(.noReceiptItem) {
      receiptHashStore.storeReceiptHash(receiptHash)

      try await retry(
        for: .noReceiptItemOnServer,
        transaction: transaction,
        subscription: subscription,
        remainingRetry: remainingRetry,
        controlIfReceiptChangedLocally: controlIfReceiptChangedLocally,
        context: context)
    }
  }

  private func retry(
    for error: VerificationReceiptError,
    transaction: Transaction?,
    subscription: StoreKitSubscription? = nil,
    remainingRetry: Int,
    controlIfReceiptChangedLocally: Bool,
    context: VerificationReceiptContext
  ) async throws {

    guard remainingRetry > 0 else {
      let errorMessage: LogMessage = "Verification failed. context: \(context)"
      switch context {
      case .purchasing:
        logger.fatal(errorMessage, error: error)
      case .postLaunch where error == .noReceiptItemOnServer:
        logger.debug(
          "Verification failed post launch due no receipt on server but can be ignored as no receipt is expected to be empty after new install"
        )
        return
      case .transactionUpdates, .postLaunch:
        logger.error(errorMessage, error: error)
      }

      throw error
    }

    logger.info("\(error), receipt will be refreshed and verification retried. context: \(context)")

    let remainingRetry = remainingRetry - 1
    let delay = pow(Double(context.retryCountMax - remainingRetry), 2)
    try await Task.sleep(for: .seconds(delay))

    try await receiptProvider.refresh()
    do {
      try await perform(
        using: transaction,
        subscription: subscription,
        remainingRetry: remainingRetry,
        controlIfReceiptChangedLocally: controlIfReceiptChangedLocally,
        context: context)
    } catch VerificationReceiptError.receiptDidNotChangeLocally {
      throw error
    }

  }
}

extension UserDeviceAPIClient.Payments.VerifyApplestoreReceipt.Body {
  init(
    transaction: Transaction?,
    subscription: StoreKitSubscription?,
    receiptData: Data,
    context: VerificationReceiptContext
  ) {
    let amount = subscription?.price.formatted(
      .number
        .grouping(.never)
        .locale(Locale(identifier: "US")))

    self.init(
      receipt: receiptData.base64EncodedString(),
      amount: amount,
      billingCountry: transaction?.storefront.countryCode,
      context: Context(context),
      currency: subscription?.priceFormatStyle.currencyCode,
      transactionIdentifier: transaction.map { String($0.id) })
  }
}

extension UserDeviceAPIClient.Payments.VerifyApplestoreReceipt.Body.Context {
  init(_ context: VerificationReceiptContext) {
    switch context {
    case .purchasing:
      self = .purchase
    case .postLaunch:
      self = .postLaunch
    case .transactionUpdates:
      self = .updates
    }
  }
}

extension Data {
  func sha256Hash() -> Data? {
    return Data(SHA256.hash(data: self))
  }
}

public struct ReceiptVerificationServiceMock: ReceiptVerificationServiceProtocol {
  public typealias VerityAction = (
    _ transaction: Transaction,
    _ subscription: StoreKitSubscription?,
    _ context: VerificationReceiptContext
  ) async throws -> Void
  let verityAction: VerityAction

  public func verifyReceipt(
    linkedTo transaction: Transaction,
    subscription: StoreKitSubscription?,
    context: VerificationReceiptContext
  ) async throws {
    try await verityAction(transaction, subscription, context)
  }
}

extension ReceiptVerificationServiceProtocol where Self == ReceiptVerificationServiceMock {
  static func mock(
    verityAction: @escaping ReceiptVerificationServiceMock.VerityAction = { _, _, _ in }
  ) -> ReceiptVerificationServiceMock {
    ReceiptVerificationServiceMock(verityAction: verityAction)
  }
}
