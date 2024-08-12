import CorePremium
import SwiftUI

@MainActor
class SettingsStatusSectionViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var status: CorePremium.Status

  private let deepLinkingService: DeepLinkingServiceProtocol

  init(
    premiumStatusProvider: PremiumStatusProvider,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.deepLinkingService = deepLinkingService
    _status = .init(initialValue: premiumStatusProvider.status)
    premiumStatusProvider
      .statusPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &$status)
  }

  func showPurchase() {
    deepLinkingService.handleLink(.premium(.planPurchase(initialView: .list)))
  }

}

extension SettingsStatusSectionViewModel {
  static func mock(status: CorePremium.Status) -> SettingsStatusSectionViewModel {
    .init(
      premiumStatusProvider: .mock(status: status),
      deepLinkingService: DeepLinkingService.fakeService)
  }
}
