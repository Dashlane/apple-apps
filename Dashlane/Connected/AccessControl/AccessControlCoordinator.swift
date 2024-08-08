import Combine
import Foundation
import SwiftUI
import UIDelight

class AccessControlCoordinator: NSObject, Coordinator {
  let baseWindow: UIWindow
  let accessControl: AccessControl
  private var cancellable: AnyCancellable?
  private var currentLockViewController: UIViewController?

  init(baseWindow: UIWindow, accessControl: AccessControl) {
    self.baseWindow = baseWindow
    self.accessControl = accessControl
    super.init()
  }

  func start() {
    cancellable = accessControl.$pendingAccess.sink { [weak self] pendingAccess in
      guard let self = self else {
        return
      }
      if pendingAccess != nil {
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

    let lockViewController = UIHostingController(rootView: AccessControlView(model: accessControl))
    lockViewController.modalPresentationStyle = .overFullScreen
    lockViewController.view.backgroundColor = .clear
    lockViewController.transitioningDelegate = self

    currentLockViewController = lockViewController

    var hostViewController = baseWindow.rootViewController
    while let topViewController = hostViewController?.presentedViewController {
      hostViewController = topViewController
    }

    hostViewController?.present(
      lockViewController,
      animated: true,
      completion: nil)
  }

  private func unlock() {
    currentLockViewController?.dismiss(animated: true)
    currentLockViewController = nil
  }
}

extension AccessControlCoordinator: UIViewControllerTransitioningDelegate {
  public func animationController(
    forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return FadeInAnimator()
  }

  public func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning?
  {
    return FadeOutAnimator()
  }
}
