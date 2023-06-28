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
    let purchasePlan: PurchasePlan
    let logger: Logger

    init(
        manager: DashlanePremiumManager,
        dashlaneAPI: DeprecatedCustomAPIClient,
        purchasePlan: PurchasePlan,
        logger: Logger

    ) {
        self.manager = manager
        self.dashlaneAPI = dashlaneAPI
        self.purchasePlan = purchasePlan
        self.logger = logger
        self.stepText = L10n.Core.planScreensPurchaseScreenTitle(purchasePlan.localizedTitle)
    }

    func purchase() {
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
            }

        func purchasingStep() {
        stepText = L10n.Core.planScreensPurchaseScreenTitle(purchasePlan.localizedTitle)
    }

        func verifyingReceiptStep() {
        stepText = L10n.Core.planScreensVerifyLabel
    }

        func updatePremiumStatusStep() {
        stepText = L10n.Core.planScreensActivateLabel
    }

        func purchaseSuccess() {
        stepText = ""

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissViewController),
                                               name: UIApplication.applicationWillResignActiveNotification,
                                               object: nil)
        Task { @MainActor in
            self.dismissSubject.send(.success(plan: self.purchasePlan))
        }
    }

                private func purchaseError(_ error: Error) {
        logger.fatal(error.localizedDescription)
        guard let error = error as? TransactionError else {
            dismissSubject.send(.failure(error))
            return
        }
        dismissSubject.send(.failure(error))
    }
}
#endif
