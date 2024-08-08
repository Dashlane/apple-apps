import Combine
import CoreSession
import CoreSettings
import CoreUserTracking
import Foundation
import NotificationKit
import SecurityDashboard
import SwiftUI
import UIDelight
import UIKit

@MainActor
class ModalCoordinator: NSObject, SubcoordinatorOwner {

  let sessionServices: SessionServicesContainer
  var subscriptions: Set<AnyCancellable> = []

  private let baseWindow: UIWindow

  var subcoordinator: Coordinator?
  private var cancellables = Set<AnyCancellable>()

  var locker: ScreenLocker? {
    sessionServices.lockService.locker.screenLocker
  }

  init(
    baseWindow: UIWindow,
    sessionServices: SessionServicesContainer
  ) {
    self.baseWindow = baseWindow
    self.sessionServices = sessionServices
  }

  func start() {
    configureTriggers()
    configureIdentityBreaches()
    configureDeviceLimitRequest()
    postAccountRecoveryKeyLogin()
  }

  func postAccountRecoveryKeyLogin() {
    guard let navigationController = self.baseWindow.rootViewController,
      sessionServices.loadingContext.isAccountRecoveryLogin
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

  func homeTabDidSelect() {
    presentModals()
  }

  func showSecurityTokenAlert(withToken token: String?) {
    let alertBuilder = SecurityTokenAlertBuilder(log: sessionServices.appServices.rootLogger)
    alertBuilder.buildAlertController(with: token) { [weak self] (alert: UIViewController?) in
      guard let alert else {
        return
      }

      self?.baseWindow.rootViewController?.topVisibleViewController.present(
        alert, animated: true, completion: nil)
    }
  }

  private func configureTriggers() {
    locker?
      .$lock
      .filter { $0 == nil }
      .sink { [weak self] _ in
        DispatchQueue.main.async {
          self?.presentModals()
        }
      }.store(in: &subscriptions)
  }

  private func presentModals() {
    let breaches = sessionServices.identityDashboardService.breachesToPresent
    guard !breaches.isEmpty else { return }
    presentIdentityBreaches(breaches: breaches) { [weak self] presentedBreaches in
      presentedBreaches.forEach {
        self?.sessionServices.identityDashboardService.markAsPresented($0)
      }
    }
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

extension ModalCoordinator {

  private func presentIdentityBreaches(
    breaches: [PopupAlertProtocol], completion: @escaping ([Breach]) -> Void
  ) {
    let viewModel = sessionServices.viewModelFactory.makeIdentityBreachAlertViewModel(
      breachesToPresent: breaches)
    let alert = IdentityBreachAlertFactory(viewModel: viewModel).alert(for: breaches)
    self.present(alert)
    completion(breaches.map { $0.breach })
  }

  private func configureIdentityBreaches() {
    sessionServices.identityDashboardService.$breachesToPresentAvailable.sink { [weak self] _ in

      guard let self = self else { return }
      let breachesAlert = self.sessionServices.identityDashboardService.breachesToPresent
      guard !breachesAlert.isEmpty else { return }

      let isSessionLocked = self.locker?.lock != nil

      guard isSessionLocked == false else {
        return
      }
      self.presentIdentityBreaches(breaches: breachesAlert) { [weak self] presentedBreaches in
        presentedBreaches.forEach {
          self?.sessionServices.identityDashboardService.markAsPresented($0)
        }
      }
    }.store(in: &subscriptions)
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
