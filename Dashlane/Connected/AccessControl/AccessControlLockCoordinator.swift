import Foundation
import Combine
import SwiftUI

class AccessControlCoordinator: NSObject, Coordinator {
    let baseWindow: UIWindow
    let accessControlLocker: AccessControl
    private var cancellable: AnyCancellable?
    private var currentLockViewController: UIViewController?

    init(baseWindow: UIWindow, accessControlLocker: AccessControl) {
        self.baseWindow = baseWindow
        self.accessControlLocker = accessControlLocker
        super.init()
    }

    func start() {
        cancellable = accessControlLocker.$shouldLock.sink { value in
            if value {
                self.lock()
            } else {
                self.unlock()
            }
        }
    }

    func dismiss() {
        cancellable?.cancel()
    }

    func lock() {
        guard currentLockViewController == nil else {
            return
        }

        let lockViewController = UIHostingController(rootView: AccessControlView(model: accessControlLocker))
        lockViewController.modalPresentationStyle = .overFullScreen
        lockViewController.view.backgroundColor = UIColor.clear
        lockViewController.transitioningDelegate = self

        currentLockViewController = lockViewController
        baseWindow.rootViewController?.present(lockViewController,
                                               animated: true,
                                               completion: nil)
    }

    private func unlock() {
        currentLockViewController?.dismiss(animated: true)
        currentLockViewController = nil
    }
}

extension AccessControlCoordinator: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimator()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutAnimator()
    }
}
