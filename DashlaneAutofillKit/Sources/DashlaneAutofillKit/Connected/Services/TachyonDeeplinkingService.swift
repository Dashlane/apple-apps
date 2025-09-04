import AuthenticationServices
import VaultKit

final class TachyonDeeplinkingService: DeepLinkingServiceProtocol {
  let context: ASCredentialProviderExtensionContext

  init(context: ASCredentialProviderExtensionContext) {
    self.context = context
  }

  func handle(_ action: VaultKit.DeepLinkAction) {
    switch action {
    case .vault(let link):
      context.open(URL(string: "dashlane:///" + link.rawDeeplink)!)
    case .frozenAccount:
      context.open(URL(string: "dashlane:///getpremium?frozen=true")!, completionHandler: nil)
    }
  }
}
