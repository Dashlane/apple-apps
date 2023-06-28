import Foundation
import CoreSession
import Combine
import LoginKit
import UIComponents

extension ModalCoordinator {
        func configureDeviceLimitRequest() {
        let sessionServices = self.sessionServices
        sessionServices
            .premiumService
            .deviceLimitPublisher()
            .throttle(for: .seconds(1000), scheduler: RunLoop.main, latest: true)
            .map { sessionServices.makeDeviceUnlinker(limit: $0) }
            .map { unlinker in
                unlinker
                    .refreshLimitAndDevices()
                    .map { unlinker }
                    .ignoreError()
            }
            .switchToLatest()
            .filter { unlinker in
                switch unlinker.mode {
                    case .monobucket, .none:
                        return false 
                    case .multiple:
                        return true
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deviceUnlinker in
                self?.startDeviceUnlink(for: deviceUnlinker)
            }.store(in: &subscriptions)
    }

    func startDeviceUnlink(for deviceUnlinker: DeviceUnlinker) {
        subcoordinator?.dismiss()

        let navigator = DashlaneNavigationController()
        navigator.navigationBar.applyStyle(.transparent())
        navigator.modalPresentationStyle = .fullScreen
        navigator.isModalInPresentation = true
        present(navigator)
        let viewModel = DeviceUnlinkingFlowViewModel(
            deviceUnlinker: deviceUnlinker,
            login: sessionServices.session.login,
            authentication: sessionServices.session.configuration.keys.serverAuthentication,
            logger: sessionServices.appServices.rootLogger[.session],
            purchasePlanFlowProvider: PurchasePlanFlowProvider(appServices: sessionServices.appServices),
            userTrackingSessionActivityReporter: sessionServices.activityReporter.activityReporter) { completion in
                switch completion {
                case .logout:
                    self.sessionServices.appServices.sessionLifeCycleHandler?.logoutAndPerform(action: .deleteCurrentSessionLocalData)
                case let .load(loadActionPublisher):
                    loadActionPublisher.send(.finish {
                        navigator.dismiss()
                    })
                }
            }

        navigator.setRootNavigation(DeviceUnlinkingFlow(viewModel: viewModel), barStyle: .transparent(), animated: true)
    }
}

extension SessionServicesContainer {
    func makeDeviceUnlinker(limit: Int) -> DeviceUnlinker {
        DeviceUnlinker(login: self.session.login,
                       currentDeviceId: self.session.configuration.keys.serverAuthentication.deviceId,
                       deviceService: DeviceService(apiClient: userDeviceAPIClient),
                       limitProvider: { $0(.success(limit)) })
    }
}

extension PremiumService {
    func deviceLimitPublisher() -> AnyPublisher<Int, Never> {
        $latestStatusFromServer
            .compactMap { $0?.capabilities.devicesLimit }
            .filter { $0.enabled }
            .compactMap { $0.info?.limit }
            .eraseToAnyPublisher()
    }
}
