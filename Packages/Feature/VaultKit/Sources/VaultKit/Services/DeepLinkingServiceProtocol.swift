public enum DeepLinkAction {
    case vault(VaultDeeplink)
}

public protocol DeepLinkingServiceProtocol {
    func handle(_ action: DeepLinkAction)
}
