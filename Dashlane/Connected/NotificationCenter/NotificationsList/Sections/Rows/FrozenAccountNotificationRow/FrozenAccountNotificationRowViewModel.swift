import CoreTypes
import Foundation
import PremiumKit

class FrozenAccountNotificationRowViewModel: SessionServicesInjecting {
  let notification: DashlaneNotification
  private let deepLinkingService: DeepLinkingServiceProtocol

  init(
    notification: DashlaneNotification,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.notification = notification
    self.deepLinkingService = deepLinkingService
  }

  func showPaywall() {
    let paywall: PlanPurchaseInitialViewRequest = .paywall(trigger: .frozenAccount)
    deepLinkingService.handleLink(.premium(.planPurchase(initialView: paywall)))
  }
}

extension FrozenAccountNotificationRowViewModel {
  static var mock: FrozenAccountNotificationRowViewModel {
    .init(
      notification: FrozenAccountNotification(
        state: .seen,
        creationDate: Date(),
        notificationActionHandler: NotificationSettings.mock
      ),
      deepLinkingService: DeepLinkingService.fakeService
    )
  }
}
