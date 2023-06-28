import Foundation
import CoreSession
import DashTypes
import CoreUserTracking
import SwiftUI
import Combine

enum DeviceUnlinkMode {
    case purchasedPremium
    case unlinkedDevices(_ devices: Set<DeviceListEntry>)
}

@MainActor
public class DeviceUnlinkingFlowViewModel: ObservableObject, LoginKitServicesInjecting {
    enum Alert {
        case unlinkFailed(Set<DeviceListEntry>, error: Error)
    }

    enum Step {
        case initial(mode: DeviceUnlinker.UnlinkMode,
                     action: (LimitedNumberOfDeviceView.Action) -> Void)
        case monobucketUnlink(device: BucketDevice,
                              action: (MonobucketUnlinkView.Action) -> Void)
        case multiDevice(limit: Int,
                         devices: [DeviceListEntry],
                         action: (UnlinkMutltiDevicesView.Action) -> Void)
        case purchasePlanFlow(flow: AnyView)
        case loading(DeviceUnlinkLoadingViewModel)
    }

    public enum Completion {
        case logout
        case load(actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>)
    }

    @Published
    var steps: [Step] = []

    @Published
    var alert: Alert?

    let deviceUnlinker: DeviceUnlinker
    let login: Login
    let authentication: ServerAuthentication
    let userTrackingSessionActivityReporter: ActivityReporterProtocol
    let logger: Logger
    let completion: (Completion) -> Void
    let purchasePlanFlowProvider: PurchasePlanFlowProvider
    let actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never> = .init()

    public convenience init(deviceUnlinker: DeviceUnlinker,
                            login: Login,
                            session: RemoteLoginSession,
                            logger: Logger,
                            purchasePlanFlowProvider: PurchasePlanFlowProvider,
                            sessionActivityReporterProvider: SessionActivityReporterProvider,
                            completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) {
        let userTrackingSessionActivityReporter = sessionActivityReporterProvider.makeSessionActivityReporter(for: login,
                                                                                                              analyticsId: session.analyticsIds)
        self.init(deviceUnlinker: deviceUnlinker,
                  login: login,
                  authentication: session.authentication,
                  logger: logger,
                  purchasePlanFlowProvider: purchasePlanFlowProvider,
                  userTrackingSessionActivityReporter: userTrackingSessionActivityReporter,
                  completion: completion)
    }

    public init(deviceUnlinker: DeviceUnlinker,
                login: Login,
                authentication: ServerAuthentication,
                logger: Logger,
                purchasePlanFlowProvider: PurchasePlanFlowProvider,
                userTrackingSessionActivityReporter: ActivityReporterProtocol,
                completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) {
        self.login = login
        self.logger = logger
        self.authentication = authentication
        self.userTrackingSessionActivityReporter = userTrackingSessionActivityReporter
        self.completion = completion
        self.deviceUnlinker = deviceUnlinker
        self.purchasePlanFlowProvider = purchasePlanFlowProvider
        initialStep()
    }

    func initialStep() {
                guard let mode = deviceUnlinker.mode else {
            self.completion(.load(actionPublisher: actionPublisher))
            return
        }

        showLimitedNumberOfDevicesView(mode: mode)
        userTrackingSessionActivityReporter.reportPageShown(.paywallDeviceSyncLimit)
    }

    func unlinkAndLoadSession(mode: DeviceUnlinkMode, using deviceUnlinker: DeviceUnlinker) {
                self.steps.append(.loading(makeDeviceUnlinkLoadingViewModel(mode: mode)))

        guard case let .unlinkedDevices(devices) = mode else {
            self.completion(.load(actionPublisher: actionPublisher))
            return
        }

        deviceUnlinker.unlink(devices) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                self.completion(.load(actionPublisher: self.actionPublisher))
            case .failure(let error):
                self.logger.error("Unlink failed", error: error)
                self.alert = .unlinkFailed(devices, error: error)
            }
        }
    }

    func showPurchasePlanFlow() {
        let flow = purchasePlanFlowProvider.makePurchasePlanFlow(for: login,
                                                                 authentication: authentication) { completion in
            guard completion == .successful else {
                return
            }
            self.unlinkAndLoadSession(mode: .purchasedPremium, using: self.deviceUnlinker)
        }
        self.steps.append(.purchasePlanFlow(flow: flow))
    }

    func retryAction(devices: Set<DeviceListEntry>) {
        self.unlinkAndLoadSession(mode: .unlinkedDevices(devices), using: deviceUnlinker)
    }
}
