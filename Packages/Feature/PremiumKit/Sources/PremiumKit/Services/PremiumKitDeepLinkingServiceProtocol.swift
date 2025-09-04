public enum DeepLinkAction {
  case goToVault
}

public protocol PremiumKitDeepLinkingServiceProtocol {
  func handle(_ action: DeepLinkAction)
}

public struct PremiumKitDeepLinkingServiceMock: PremiumKitDeepLinkingServiceProtocol {
  public init() {}
  public func handle(_ action: DeepLinkAction) {

  }
}
