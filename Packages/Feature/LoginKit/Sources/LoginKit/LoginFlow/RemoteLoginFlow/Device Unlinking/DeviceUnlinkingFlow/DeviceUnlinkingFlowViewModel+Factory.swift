import Foundation
import CoreSession
import CoreUserTracking

extension DeviceUnlinkingFlowViewModel {
    func showLimitedNumberOfDevicesView(mode: DeviceUnlinker.UnlinkMode) {
        let action: (LimitedNumberOfDeviceView.Action) -> Void = { [weak self] action in
            guard let self = self else {
                return
            }

            switch action {
            case .unlink:
                let event = UserEvent.CallToAction(callToActionList: [.unlink, .allOffers], chosenAction: .unlink, hasChosenNoAction: false)
                self.userTrackingSessionActivityReporter.report(event)
                self.showUnlinkDevice(mode: mode)
            case .upgrade:
                let event = UserEvent.CallToAction(callToActionList: [.unlink, .allOffers], chosenAction: .allOffers, hasChosenNoAction: false)
                self.userTrackingSessionActivityReporter.report(event)
                self.showPurchasePlanFlow()
            case .logout:
                let event = UserEvent.CallToAction(callToActionList: [.unlink, .allOffers], chosenAction: nil, hasChosenNoAction: true)
                self.userTrackingSessionActivityReporter.report(event)
                self.completion(.logout)
            }
        }

        self.steps.append(.initial(mode: mode, action: action))
    }

    private func showUnlinkDevice(mode: DeviceUnlinker.UnlinkMode) {
        switch mode {
        case .monobucket:
            guard let device = deviceUnlinker.currentUserDevices.monobucketOwner() else {
                unlinkAndLoadSession(mode: .unlinkedDevices([]), using: deviceUnlinker)
                return
            }
            self.showMonobucketUnlinkView(device: device)
        case let .multiple(limit):
            self.showUnlinkMutltiDevicesView(limit: limit)
        }
        userTrackingSessionActivityReporter.reportPageShown(.paywallDeviceSyncLimitUnlinkDevice)
    }

    private func showMonobucketUnlinkView(device: BucketDevice) {
        let action: (MonobucketUnlinkView.Action) -> Void = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .unlink:
                let event = UserEvent.CallToAction(callToActionList: [.unlink], chosenAction: .unlink, hasChosenNoAction: false)
                self.userTrackingSessionActivityReporter.report(event)
                                self.unlinkAndLoadSession(mode: .unlinkedDevices([]), using: self.deviceUnlinker)

            case .cancel:
                let event = UserEvent.CallToAction(callToActionList: [.unlink], chosenAction: nil, hasChosenNoAction: true)
                self.userTrackingSessionActivityReporter.report(event)
            }
        }

        self.steps.append(.monobucketUnlink(device: device, action: action))
    }

    func showUnlinkMutltiDevicesView(limit: Int) {
        let devices = deviceUnlinker.currentUserDevices.sorted {
            $0.displayedDevice.lastActivityDate > $1.displayedDevice.lastActivityDate
        }

        let action: (UnlinkMutltiDevicesView.Action) -> Void = { [weak self] action in
            guard let self = self else {
                return
            }
            switch action {
            case .upgrade:
                self.showPurchasePlanFlow()
            case let .unlink(devices):
                self.unlinkAndLoadSession(mode: .unlinkedDevices(devices),
                                          using: self.deviceUnlinker)
            case .cancel:
                break
            }
        }

        self.steps.append(.multiDevice(limit: limit,
                                       devices: devices,
                                       action: action))
    }

    func makeDeviceUnlinkLoadingViewModel(mode: DeviceUnlinkMode) -> DeviceUnlinkLoadingViewModel {
        .init(mode: mode, actionPublisher: actionPublisher)
    }
}
