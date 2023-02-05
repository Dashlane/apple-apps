#if canImport(UIKit)
import Combine
import DashTypes
import Foundation
import CorePremium
import CoreLocalization
import UIKit

final class PurchaseProcessViewModel: ObservableObject {

    @Published
    var stepText: String

    private let dismissSubject: PassthroughSubject<PurchaseProcessView.Action, Never> = .init()
    var dismissPublisher: AnyPublisher<PurchaseProcessView.Action, Never> {
        dismissSubject.eraseToAnyPublisher()
    }

    private let manager: DashlanePremiumManager
    private let dashlaneAPI: DeprecatedCustomAPIClient
    private let logger: PurchaseProcessLogger
    let purchasePlan: PurchasePlan

    init(
        manager: DashlanePremiumManager,
        dashlaneAPI: DeprecatedCustomAPIClient,
        logger: PurchaseProcessLogger,
        purchasePlan: PurchasePlan
    ) {
        self.manager = manager
        self.dashlaneAPI = dashlaneAPI
        self.logger = logger
        self.purchasePlan = purchasePlan
        self.stepText = L10n.Core.planScreensPurchaseScreenTitle(purchasePlan.localizedTitle)
    }

    func purchase() {
        purchaseUsageLog(action: .openStore, errorCode: nil)
        purchase(purchasePlan) { [weak self] purchaseStatus in
            self?.handlePurchaseStatus(purchaseStatus)
        }
    }

    private func handlePurchaseStatus(_ purchaseStatus: PurchaseStatus) {
        switch purchaseStatus {
        case .deferred:
            purchaseDeferred()
        case .purchasing:
            purchasingStep()
        case .verifyingReceipt:
            verifyingReceiptStep()
        case .updatingPremiumStatus:
            updatePremiumStatusStep()
        case .success:
            purchaseSuccess()
        case .error(let error):
            purchaseError(error)
        }
    }

    @objc private func dismissViewController() {
        dismissSubject.send(.cancellation)
    }
}

private extension PurchaseProcessViewModel {

    func purchase(_ plan: PurchasePlan, completion: @escaping (PurchaseStatus) -> Void) {
        manager.purchase(plan, authenticatedAPIClient: dashlaneAPI, completion: completion)
    }

        func purchaseDeferred() {
                basicLog(type: LogType.info, "IAP Deferred")
        purchaseUsageLog(action: .purchaseDeferred, errorCode: nil)
    }

        func purchasingStep() {
        stepText = L10n.Core.planScreensPurchaseScreenTitle(purchasePlan.localizedTitle)

        basicLog(type: LogType.info, "IAP Purchasing")
        purchaseUsageLog(action: .purchasing, errorCode: nil)
    }

        func verifyingReceiptStep() {
        stepText = L10n.Core.planScreensVerifyLabel

        basicLog(type: LogType.info, "IAP Verifying receipt")
        purchaseUsageLog(action: .verifyingReceipt, errorCode: nil)
    }

        func updatePremiumStatusStep() {
        stepText = L10n.Core.planScreensActivateLabel

        basicLog(type: LogType.info, "IAP Updating premium status")
    }

        func purchaseSuccess() {
        stepText = ""

        logPremium(type: LogPremiumType.yearlySuccessful)
        purchaseUsageLog(action: .purchaseComplete, errorCode: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissViewController),
                                               name: UIApplication.applicationWillResignActiveNotification,
                                               object: nil)
        Task { @MainActor in
            self.dismissSubject.send(.success(plan: self.purchasePlan))
        }
    }

                private func purchaseError(_ error: Error) {
        guard let error = error as? TransactionError else {
            purchaseUsageLog(action: .error, errorCode: String(-1))
            dismissSubject.send(.failure(error))
            return
        }
        switch error {
        case .clientInvalid:
            purchaseUsageLog(action: .error, errorCode: String(TransactionError.clientInvalid.code))
        case .receiptInvalid:
            basicLog(type: LogType.error, "validateReceipt failure receiptInvalid")
            logPremium(type: LogPremiumType.yearlyReceiptFailedValidation)
            logPremium(type: LogPremiumType.yearlyErrorOccurredForPurchase)
            purchaseUsageLog(action: .error, errorCode: String(TransactionError.receiptInvalid.code))
        default:
            purchaseUsageLog(action: .error, errorCode: String(error.code))
        }
        dismissSubject.send(.failure(error))
    }
}

private extension PurchaseProcessViewModel {
    func basicLog(type: LogType, _ message: String) {
        logger.basicLog(type: type, message)
    }

    func logPremium(type: LogPremiumType) {
        logger.logPremium(type: type)
    }

    func purchaseUsageLog(action: PurchaseAction, errorCode: String?) {
        logger.purchaseUsageLog(action: action, errorCode: errorCode)
    }
}

public enum PurchaseAction: String {
    case openStore
    case purchasing
    case paymentSuccess
    case verifyingReceipt
    case purchaseDeferred
    case purchaseComplete
    case error
}

struct PurchaseProcessLogger {

    private let selectedItem: PurchasePlan
    private let logger: Logger
    private let premiumStatusLogger: PremiumStatusLogger

    init(selectedItem: PurchasePlan, logger: Logger, premiumStatusLogger: PremiumStatusLogger) {
        self.selectedItem = selectedItem
        self.logger = logger
        self.premiumStatusLogger = premiumStatusLogger
    }

    func basicLog(type: LogType, _ message: String) {
        switch type {
        case .info:
            logger.info(message)
        case .warning:
            logger.warning(message)
        case .error:
            logger.error(message)
        }
    }

    func logPremium(type: LogPremiumType) {
        premiumStatusLogger.logPremium(type: type)
    }

    func purchaseUsageLog(action: PurchaseAction, errorCode: String?) {
        premiumStatusLogger.logPurchase(
            selectedItem.kind,
            action: action.rawValue,
            errorCode: errorCode,
            origin: nil)
    }
}
#endif
