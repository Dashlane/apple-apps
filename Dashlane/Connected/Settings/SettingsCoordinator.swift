import UIKit
import SwiftUI
import CoreSession
import CoreFeature

final class SettingsCoordinator: TabCoordinator, SubcoordinatorOwner {
    var subcoordinator: Coordinator?

    let viewController: UIViewController

    private var navigator: DashlaneNavigationController? {
        viewController as? DashlaneNavigationController
    }

    let sessionServices: SessionServicesContainer

    let tabBarImage = NavigationImageSet(image: FiberAsset.tabIconSettingsOff,
                                         selectedImage: FiberAsset.tabIconSettingsOn)

    let sidebarImage = NavigationImageSet(image: FiberAsset.sidebarSettings,
                                          selectedImage: FiberAsset.sidebarSettingsSelected)

    let title: String = L10n.Localizable.tabSettingsTitle

    let tag: Int = 4

    let id = UUID()

    init(sessionServices: SessionServicesContainer) {
        let viewModel = sessionServices.viewModelFactory.makeSettingsFlowViewModel()
        let rootView = SettingsFlowView(viewModel: viewModel)
        self.viewController = UIHostingController(rootView: rootView)
        self.sessionServices = sessionServices
    }

    func start() {}

    func showPremium() {
        sessionServices.appServices.deepLinkingService.handleLink(.other(.getPremium))
    }
}

extension SettingsCoordinator {
    func launchMasterPasswordChanger() {
        guard let navigator = navigator else { return }
        self.startSubcoordinator(AccountMigrationCoordinator(type: .masterPasswordToMasterPassword,
                                                             navigator: navigator,
                                                             sessionServices: sessionServices,
                                                             authTicket: nil,
                                                             logger: sessionServices.appServices.rootLogger) { [weak self] result in

            if case let .success(response) = result, case let .finished(session) = response {
                self?.sessionServices.appServices.sessionLifeCycleHandler?.logoutAndPerform(action: .startNewSession(session, reason: .masterPasswordChanged))
            } else {
                self?.subcoordinator = nil
            }
        })
    }
}
