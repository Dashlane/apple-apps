import PremiumKit

extension DeepLinkingService: PremiumKitDeepLinkingServiceProtocol {
  func handle(_ action: PremiumKit.DeepLinkAction) {
    switch action {
    case .goToVault:
      handleLink(.vault(.list(.credentials)))
    }
  }
}
