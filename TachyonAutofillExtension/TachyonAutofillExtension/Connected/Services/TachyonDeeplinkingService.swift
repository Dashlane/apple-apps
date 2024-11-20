import AuthenticationServices
import VaultKit

final class TachyonDeeplinkingService: VaultKit.DeepLinkingServiceProtocol {
  let context: ASCredentialProviderExtensionContext

  init(context: ASCredentialProviderExtensionContext) {
    self.context = context
  }

  func handle(_ action: VaultKit.DeepLinkAction) {
    switch action {
    case .vault(let link):
      context.open(URL(string: "dashlane:///" + link.rawDeeplink)!)
    case .frozenAccount:
      context.open(URL(string: "dashlane:///")!, completionHandler: nil)
    }
  }
}
