import Combine
import CoreLocalization
import CorePremium
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import UIKit

final class PurchaseProcessViewModel: ObservableObject {

  @Published
  var stepText: String

  private let dismissSubject: PassthroughSubject<PurchaseProcessView.Action, Never> = .init()
  var dismissPublisher: AnyPublisher<PurchaseProcessView.Action, Never> {
    dismissSubject.eraseToAnyPublisher()
  }

  private let purchaseService: PurchaseService
  private let userDeviceAPIClient: UserDeviceAPIClient
  let purchasePlan: PurchasePlan
  let logger: Logger

  init(
    purchaseService: PurchaseService,
    userDeviceAPIClient: UserDeviceAPIClient,
    purchasePlan: PurchasePlan,
    logger: Logger

  ) {
    self.purchaseService = purchaseService
    self.userDeviceAPIClient = userDeviceAPIClient
    self.purchasePlan = purchasePlan
    self.logger = logger
    self.stepText = CoreL10n.planScreensPurchaseScreenTitle(purchasePlan.localizedTitle)
  }

  func purchase() {
    Task {
      do {
        for try await purchaseStatus in await purchaseService.purchase(purchasePlan) {
          self.handlePurchaseStatus(purchaseStatus)
        }
      } catch {
        purchaseError(error)
      }
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
    case .cancelled:
      return
    case .success:
      purchaseSuccess()
    }
  }

  @objc private func dismissViewController() {
    dismissSubject.send(.cancellation)
  }
}

extension PurchaseProcessViewModel {

  fileprivate func purchaseDeferred() {
  }

  fileprivate func purchasingStep() {
    stepText = CoreL10n.planScreensPurchaseScreenTitle(purchasePlan.localizedTitle)
  }

  fileprivate func verifyingReceiptStep() {
    stepText = CoreL10n.planScreensVerifyLabel
  }

  fileprivate func updatePremiumStatusStep() {
    stepText = CoreL10n.planScreensActivateLabel
  }

  fileprivate func purchaseSuccess() {
    stepText = ""

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(dismissViewController),
      name: UIApplication.applicationWillResignActiveNotification,
      object: nil)
    Task { @MainActor in
      self.dismissSubject.send(.success(plan: self.purchasePlan))
    }
  }

  private func purchaseError(_ error: Error) {
    logger.fatal("purchase failed", error: error)
    dismissSubject.send(.failure(error))
  }
}
