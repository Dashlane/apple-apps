import Combine
import CoreSession
import CoreSettings
import Foundation
import NotificationKit
import SecurityDashboard
import SwiftUI
import UIDelight
import UIKit
import UserTrackingFoundation

@MainActor
class ModalCoordinator: NSObject, SubcoordinatorOwner {

  let sessionServices: SessionServicesContainer
  var subscriptions: Set<AnyCancellable> = []

  private let baseWindow: UIWindow

  var subcoordinator: Coordinator?
  private var cancellables = Set<AnyCancellable>()

  init(
    baseWindow: UIWindow,
    sessionServices: SessionServicesContainer
  ) {
    self.baseWindow = baseWindow
    self.sessionServices = sessionServices
  }

  func start() {
    configureDeviceLimitRequest()
    postAccountRecoveryKeyLogin()
  }

  func postAccountRecoveryKeyLogin() {
    guard let navigationController = self.baseWindow.rootViewController,
      sessionServices.loadingContext.isAccountRecoveryLogin,
      !sessionServices.session.authenticationMethod.isInvisibleMasterPassword
    else {
      return
    }
    let view = AccountRecoveryKeyDisabledAlertView(
      model: self.sessionServices.viewModelFactory.makeAccountRecoveryKeyDisabledAlertViewModel(
        authenticationMethod: self.sessionServices.session.authenticationMethod))
    navigationController.modalPresentationStyle = .fullScreen
    let viewController = UIHostingController(rootView: view)
    viewController.isModalInPresentation = true
    navigationController.present(viewController, animated: false)
  }

  func present(_ viewController: UIViewController) {
    DispatchQueue.main.async {
      self.baseWindow.rootViewController?.topVisibleViewController.present(
        viewController,
        animated: true,
        completion: nil)
    }
  }
}

extension UIViewController {

  var topVisibleViewController: UIViewController {
    var current = self

    while let topViewController = current.presentedViewController, !topViewController.isAlert {
      current = topViewController
    }
    return current
  }

  var isAlert: Bool {
    return type(of: self) == UIAlertController.self
  }
}

extension ModalCoordinator: UIViewControllerTransitioningDelegate {
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
