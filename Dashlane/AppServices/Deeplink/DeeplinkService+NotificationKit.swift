import Foundation
import NotificationKit

extension DeepLinkingService: NotificationKitDeepLinkingServiceProtocol {

  func handle(_ action: DeepLinkAction) {
    switch action {
    case let .goToSettings(component):
      switch component {
      case .root:
        return self.handleLink(.settings(.root))
      case .enableResetMasterPassword:
        return self.handleLink(.settings(.security(.enableResetMasterPassword)))
      case .recoveryKey:
        return self.handleLink(.settings(.security(.recoveryKey)))
      }
    case .goToPremium:
      handleLink(.premium(.getPremium))
    case let .displayPaywall(capability):
      handleLink(
        .premium(.planPurchase(initialView: .paywall(trigger: .capability(key: capability)))))
    case .displayFrozenPaywall:
      handleLink(.premium(.planPurchase(initialView: .paywall(trigger: .frozenAccount))))
    case .importFromLastPass:
      let link = DeepLink.importMethod(
        ImportMethodDeeplink.import(ImportMethodDeeplink.Method.lastpass))
      handleLink(link)
    }
  }
}
