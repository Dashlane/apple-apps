import CoreFeature
import CorePremium
import CoreTypes
import SwiftUI

@MainActor
class SettingsStatusSectionViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var status: CorePremium.Status

  @Published
  var vaultState: VaultState = .default

  private let vaultStateService: VaultStateServiceProtocol
  private let deepLinkingService: DeepLinkingServiceProtocol

  init(
    premiumStatusProvider: PremiumStatusProvider,
    vaultStateService: VaultStateServiceProtocol,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.deepLinkingService = deepLinkingService
    self.vaultStateService = vaultStateService
    _status = .init(initialValue: premiumStatusProvider.status)
    premiumStatusProvider
      .statusPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &$status)

    vaultStateService
      .vaultStatePublisher()
      .receive(on: DispatchQueue.main)
      .assign(to: &$vaultState)
  }

  func showPurchase() {
    deepLinkingService.handleLink(.premium(.planPurchase(initialView: .list)))
  }

}

extension SettingsStatusSectionViewModel {
  static func mock(status: CorePremium.Status) -> SettingsStatusSectionViewModel {
    .init(
      premiumStatusProvider: .mock(status: status),
      vaultStateService: .mock(),
      deepLinkingService: DeepLinkingService.fakeService)
  }
}
