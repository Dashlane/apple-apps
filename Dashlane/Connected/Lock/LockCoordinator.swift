import Foundation
import Combine
import SwiftUI
import CoreSession
import DashTypes

class LockCoordinator: NSObject, SubcoordinatorOwner {
        struct ModalLockSession {
        let window: UIWindow
        let backgroundViewController: UIViewController
        let lockViewController: DashlaneNavigationController
    }

    let baseWindow: UIWindow
    let lockService: LockService
    let sessionServices: SessionServicesContainer
    var subcoordinator: Coordinator?
    private var screenLockerCoordinator: ScreenLockerCoordinator?

    init(sessionServices: SessionServicesContainer,
         baseWindow: UIWindow) {
        self.baseWindow = baseWindow
        self.lockService = sessionServices.lockService
        self.sessionServices = sessionServices
        super.init()
        if let screenLocker = lockService.locker.screenLocker {
            self.screenLockerCoordinator = .init(screenLocker: screenLocker,
                                                 sessionServices: sessionServices,
                                                 baseWindow: baseWindow,
                                                 showBiometryChangeIfNeeded: { [weak self] in self?.showBiometryChangeIfNeeded() })
        } else {
            self.screenLockerCoordinator = nil
        }
    }

    func start() {
        screenLockerCoordinator?.start()
    }

    func dismiss() {
        screenLockerCoordinator?.unlock(animated: false)
        screenLockerCoordinator?.dismiss()
    }

    func showBiometryChangeIfNeeded() {
        lockService.biometricSetUpdatesService.checkForUpdatesInBiometricSet()

                guard let rootViewController = baseWindow.rootViewController else {
            return
        }

        if let setup = lockService.biometricSetUpdatesService.setupToReactivate() {
            let alert = UIAlertController.makeReactivationRequestAlert(forSetup: setup, lockService: lockService, resetMasterPasswordService: sessionServices.resetMasterPasswordService)
            rootViewController.present(alert, animated: true)
        }
    }
}
