import Foundation
import Combine
import UIComponents
import UIDelight
import UIKit

class ScreenLockerCoordinator: NSObject, SubcoordinatorOwner {

        struct ModalLockSession {
        let window: UIWindow
        let backgroundViewController: UIViewController
        let lockViewController: DashlaneNavigationController
    }

    private let screenLocker: ScreenLocker
    let baseWindow: UIWindow
    private var currentLockSession: ModalLockSession?
    private var cancellables = Set<AnyCancellable>()
    private var lastLock: ScreenLocker.Lock?
    let sessionServices: SessionServicesContainer

    private var showBiometryChangeIfNeeded: () -> Void
    var subcoordinator: Coordinator?

    init(screenLocker: ScreenLocker,
         sessionServices: SessionServicesContainer,
         baseWindow: UIWindow,
         showBiometryChangeIfNeeded: @escaping () -> Void) {
        self.screenLocker = screenLocker
        self.sessionServices = sessionServices
        self.baseWindow = baseWindow
        self.showBiometryChangeIfNeeded = showBiometryChangeIfNeeded
    }

    func start() {
        screenLocker
            .$lock
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lock in
                guard let self = self else {
                    return
                }
                if lock != nil {
                    self.lastLock = lock
                                        let animated = lock != .privacyShutter
                    self.lock(animated: animated)
                } else {
                    self.unlock()
                }
            }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.lockAfterAppBecomeActive()
            }.store(in: &cancellables)
    }

    func dismiss() {
        cancellables.forEach {
            $0.cancel()
        }
    }

        public func lockAfterAppBecomeActive() {
        if let lock = screenLocker.lock, case ScreenLocker.Lock.secure = lock {
            self.lock(animated: false)
        }
    }

    private func lock(animated: Bool = true, completion: (() -> Void)? = nil) {
                guard currentLockSession == nil else {
            return
        }

        let modalWindow = makeLockWindow()

        let backgroundViewController = UIViewController()
        backgroundViewController.view = baseWindow.snapshotView(afterScreenUpdates: false)
        modalWindow.rootViewController = backgroundViewController

        let lockViewController = DashlaneNavigationController()
        lockViewController.transitioningDelegate = self
        lockViewController.modalPresentationStyle = .fullScreen

        let lockViewModel = sessionServices.viewModelFactory.makeLockViewModel(locker: screenLocker) { [weak self] in
            self?.launchMasterPasswordChanger()
        }

        let lockView = LockView(viewModel: lockViewModel)
        lockViewController.setRootNavigation(lockView)

        currentLockSession = ModalLockSession(window: modalWindow,
                                              backgroundViewController: backgroundViewController,
                                              lockViewController: lockViewController)

        modalWindow.makeKeyAndVisible()
        modalWindow.isHidden = false

        modalWindow.rootViewController?.present(lockViewController,
                                                animated: UIApplication.shared.applicationState == .active && animated,
                                                completion: completion)

    }

    func unlock(animated: Bool = true) {
        guard let modalSession = currentLockSession else {
            return
        }
        self.currentLockSession = nil

        modalSession.backgroundViewController.view = baseWindow.snapshotView(afterScreenUpdates: false)
        modalSession.lockViewController.dismiss(animated: animated) { [weak self] in
            modalSession.window.isHidden = true
            self?.showBiometryChangeIfNeeded()
        }
    }
}

extension ScreenLockerCoordinator {
    private func makeLockWindow() -> UIWindow {
        let modalWindow: UIWindow
        if let scene = baseWindow.windowScene {
            modalWindow = UIWindow(windowScene: scene)
        } else {
            modalWindow = UIWindow(frame: UIScreen.main.bounds)
        }

        modalWindow.backgroundColor = .black
        modalWindow.windowLevel = .statusBar + 1

        return modalWindow
    }
}

extension ScreenLockerCoordinator {
    func launchMasterPasswordChanger() {
        guard let currentViewController = currentLockSession?.lockViewController else {
                        return
        }
        self.startSubcoordinator(AccountMigrationCoordinator(type: .masterPasswordToMasterPassword,
                                                             navigator: currentViewController,
                                                             sessionServices: sessionServices,
                                                             authTicket: nil,
                                                             logger: sessionServices.appServices.rootLogger) { [weak self] result in
            if case let .success(response) = result, case let .finished(session) = response {

                self?.sessionServices.appServices.sessionLifeCycleHandler?.logoutAndPerform(action: .startNewSession(session, reason: .masterPasswordChanged))
            }
        })
    }
}

extension ScreenLockerCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if lastLock == .privacyShutter {
            return FadeInAnimator(duration: 0.2)
        } else {
            return LockAnimator(isOpening: true)
        }
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if screenLocker.lock == .privacyShutter {
            return FadeOutAnimator(duration: 0.2)
        } else {
            return LockAnimator(isOpening: false)
        }
    }
}
