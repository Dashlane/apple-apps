import Foundation
import CoreSession
import CoreUserTracking

extension DeviceUnlinkingFlowViewModel {
    func showLimitedNumberOfDevicesView(mode: DeviceUnlinker.UnlinkMode,
                                        logger: DeviceLimitUsageLogger) {
        let action: (LimitedNumberOfDeviceView.Action) -> Void = { [weak self] action in
            guard let self = self else {
                return
            }

            switch action {
            case .unlink:
                logger.log(.limitPrompt, action: .startUnlink)
                let event = UserEvent.CallToAction(callToActionList: [.unlink, .allOffers], chosenAction: .unlink, hasChosenNoAction: false)
                self.userTrackingSessionActivityReporter.report(event)
                self.showUnlinkDevice(mode: mode, logger: logger)
            case .upgrade:
                logger.log(.limitPrompt, action: .seePremium)
                let event = UserEvent.CallToAction(callToActionList: [.unlink, .allOffers], chosenAction: .allOffers, hasChosenNoAction: false)
                self.userTrackingSessionActivityReporter.report(event)
                self.showPurchasePlanFlow()
            case .logout:
                logger.log(.limitPrompt, action: .logout)
                let event = UserEvent.CallToAction(callToActionList: [.unlink, .allOffers], chosenAction: nil, hasChosenNoAction: true)
                self.userTrackingSessionActivityReporter.report(event)
                self.completion(.logout)
            }
        }

        self.steps.append(.initial(mode: mode, action: action))
    }

    private func showUnlinkDevice(mode: DeviceUnlinker.UnlinkMode,
                                  logger: DeviceLimitUsageLogger) {
        switch mode {
        case .monobucket:
            guard let device = deviceUnlinker.currentUserDevices.monobucketOwner() else {
                unlinkAndLoadSession(mode: .unlinkedDevices([]), using: deviceUnlinker)
                return
            }
            self.showMonobucketUnlinkView(device: device, logger: logger)
        case let .multiple(limit):
            self.showUnlinkMutltiDevicesView(limit: limit, logger: logger)
        }
        logger.log(.unlinkScreen, action: .seen)
        userTrackingSessionActivityReporter.reportPageShown(.paywallDeviceSyncLimitUnlinkDevice)
    }

    private func showMonobucketUnlinkView(device: BucketDevice, logger: DeviceLimitUsageLogger) {
        let action: (MonobucketUnlinkView.Action) -> Void = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .unlink:
                logger.log(.unlinkScreen, action: .unlink)
                let event = UserEvent.CallToAction(callToActionList: [.unlink], chosenAction: .unlink, hasChosenNoAction: false)
                self.userTrackingSessionActivityReporter.report(event)
                                self.unlinkAndLoadSession(mode: .unlinkedDevices([]), using: self.deviceUnlinker)

            case .cancel:
                logger.log(.unlinkScreen, action: .cancelUnlink)
                let event = UserEvent.CallToAction(callToActionList: [.unlink], chosenAction: nil, hasChosenNoAction: true)
                self.userTrackingSessionActivityReporter.report(event)
            }
        }

        self.steps.append(.monobucketUnlink(device: device, action: action))
    }

    func showUnlinkMutltiDevicesView(limit: Int, logger: DeviceLimitUsageLogger) {
        let devices = deviceUnlinker.currentUserDevices.sorted {
            $0.displayedDevice.lastActivityDate > $1.displayedDevice.lastActivityDate
        }

        let action: (UnlinkMutltiDevicesView.Action) -> Void = { [weak self] action in
            guard let self = self else {
                return
            }
            switch action {
            case let .upgrade(devices):
                logger.log(.unlinkScreen, action: .upgrade, numberOfSelectedDevices: devices.count)
                self.showPurchasePlanFlow()
            case let .unlink(devices):
                logger.log(.unlinkScreen, action: .unlink, numberOfSelectedDevices: devices.count)
                self.unlinkAndLoadSession(mode: .unlinkedDevices(devices),
                                          using: self.deviceUnlinker)
            case .cancel:
                logger.log(.unlinkScreen, action: .cancelUnlink)
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
