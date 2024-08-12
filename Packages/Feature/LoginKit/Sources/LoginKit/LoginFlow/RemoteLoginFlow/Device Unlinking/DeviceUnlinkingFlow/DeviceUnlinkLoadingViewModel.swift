import Combine
import Foundation

public enum DeviceUnlinkLoadingAction {
  case finish(onComplete: () -> Void)
}

struct DeviceUnlinkLoadingViewModel {
  let mode: DeviceUnlinkMode
  let actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>
}

extension DeviceUnlinkLoadingViewModel {
  static var mock: DeviceUnlinkLoadingViewModel {
    .init(mode: .purchasedPremium, actionPublisher: .init())
  }
}
