import Foundation

public class FrozenBannerViewModel: ObservableObject {
  private let deeplinkingService: NotificationKitDeepLinkingServiceProtocol

  public init(
    deeplinkingService: NotificationKitDeepLinkingServiceProtocol
  ) {
    self.deeplinkingService = deeplinkingService
  }

  func displayPaywall() {
    deeplinkingService.handle(.displayFrozenPaywall)
  }
}

extension FrozenBannerViewModel {
  public static var mock: FrozenBannerViewModel {
    .init(
      deeplinkingService: NotificationKitDeepLinkingServiceMock()
    )
  }
}
