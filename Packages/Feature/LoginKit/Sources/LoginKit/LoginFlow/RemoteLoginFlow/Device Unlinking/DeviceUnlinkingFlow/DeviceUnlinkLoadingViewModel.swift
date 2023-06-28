import Foundation
import Combine

public enum DeviceUnlinkLoadingAction {
    case finish(onComplete: () -> Void)
}

struct DeviceUnlinkLoadingViewModel {

    let mode: DeviceUnlinkMode
    let actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>

    init(mode: DeviceUnlinkMode,
         actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>) {
        self.actionPublisher = actionPublisher
        self.mode = mode
    }
}

extension DeviceUnlinkLoadingViewModel {
    static var mock: DeviceUnlinkLoadingViewModel {
        .init(mode: .purchasedPremium, actionPublisher: .init())
    }
}
