import VaultKit

extension DeepLinkingService: VaultKit.DeepLinkingServiceProtocol {
  func handle(_ action: VaultKit.DeepLinkAction) {
    switch action {
    case let .vault(link):
      handleLink(.vault(link))
    case .frozenAccount:
      handleLink(.premium(.planPurchase(initialView: .paywall(trigger: .frozenAccount))))
    }
  }
}
