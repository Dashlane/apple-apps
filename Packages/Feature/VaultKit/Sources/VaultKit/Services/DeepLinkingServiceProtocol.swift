public enum DeepLinkAction {
  case vault(VaultDeeplink)
  case frozenAccount
}

public protocol DeepLinkingServiceProtocol {
  func handle(_ action: DeepLinkAction)
}

public struct FakeDeepLinkingService: DeepLinkingServiceProtocol {
  public func handle(_ action: DeepLinkAction) {}
}
