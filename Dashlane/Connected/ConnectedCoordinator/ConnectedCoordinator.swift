import Combine
import CoreCategorizer
import CorePersonalData
import CoreSession
import CoreSync
import DesignSystem
import LoginKit
import Lottie
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit
import VaultKit

class ConnectedCoordinator: NSObject, Coordinator, SubcoordinatorOwner {
  let sessionServices: SessionServicesContainer
  let window: UIWindow
  var subcoordinator: Coordinator?
  let lockCoordinator: LockCoordinator
  let accessControlCoordinator: AccessControlCoordinator
  let modalCoordinator: ModalCoordinator
  let onboardingService: OnboardingService
  private let appTrackingTransparencyService: AppTrackingTransparencyService
  var subscriptions = Set<AnyCancellable>()
  private weak var logoutHandler: SessionLifeCycleHandler?
  private var syncStatusSubscription: AnyCancellable?

  lazy var connectedViewController: UIViewController = DashlaneHostingViewController(
    rootView: ConnectedRootView(model: self.sessionServices.makeConnectedRootViewModel()))

  private let mainMenuHandler: SessionMainMenuHandler

  init(
    sessionServices: SessionServicesContainer,
    window: UIWindow,
    logoutHandler: SessionLifeCycleHandler,
    applicationMainMenuHandler: ApplicationMainMenuHandler
  ) {
    self.window = window
    self.lockCoordinator = LockCoordinator(
      sessionServices: sessionServices,
      baseWindow: window)
    self.sessionServices = sessionServices
    self.accessControlCoordinator = AccessControlCoordinator(
      baseWindow: window,
      accessControl: sessionServices.accessControl)
    self.modalCoordinator = .init(baseWindow: window, sessionServices: sessionServices)
    self.onboardingService = sessionServices.onboardingService
    self.logoutHandler = logoutHandler
    self.appTrackingTransparencyService = AppTrackingTransparencyService(
      sessionServices: sessionServices)
    self.mainMenuHandler = SessionMainMenuHandler(
      applicationHandler: applicationMainMenuHandler,
      syncService: sessionServices.syncService,
      bridge: MainMenuBarBridge.shared,
      logger: sessionServices.appServices.rootLogger)
  }

  func start() {
    showConnectedView()
    syncStatusSubscription = sessionServices.syncService.$syncStatus
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        self?.syncStatusDidChange(to: status)
      }

    if case .accountCreation = sessionServices.loadingContext {
      appTrackingTransparencyService.requestAuthorization()
    }

    if onboardingService.shouldShowAccountCreationOnboarding {
      Task {
        await DefaultAnimationCache.sharedCache.preloadAnimationsForGuidedOnboarding()
      }
    }
    configureAppearance()
  }

  func configureAppearance() {
    UITableView.appearance().backgroundColor = UIColor.ds.background.default
    UITableView.appearance().sectionHeaderTopPadding = 0.0
  }

  func dismiss(completion: @escaping () -> Void) {
    mainMenuHandler.unload()
    lockCoordinator.dismiss()
    accessControlCoordinator.dismiss()
    syncStatusSubscription?.cancel()
    completion()
  }

  private func showConnectedView() {
    if onboardingService.shouldShowAccountCreationOnboarding {
      showOnboarding()
    } else if let biometry = Device.biometryType,
      onboardingService.shouldShowFastLocalSetupForFirstLogin
    {
      showFastLocalSetup(for: biometry)
    } else if Device.isMac, onboardingService.shouldShowFastLocalSetupForFirstLogin {
      showFastLocalSetupForRememberMasterPassword()
    } else {
      transitionToConnectedViewController()
    }
  }

  func transitionToConnectedViewController() {
    let backgroundViewController = makeBackgroundViewController()
    self.window.rootViewController = connectedViewController

    self.window.rootViewController?.present(backgroundViewController, animated: false) {
      backgroundViewController.dismiss(animated: true) {

        if self.onboardingService.shouldShowBiometricsOrPinOnboardingForSSO {
          self.showBiometricsOrPinOnboarding()
        } else {
          self.finishLaunch()
        }
      }
    }
  }

  func makeBackgroundViewController() -> UIViewController {
    let backgroundViewController = UIViewController()
    backgroundViewController.view = self.window.rootViewController?.view.snapshotView(
      afterScreenUpdates: false)
    backgroundViewController.transitioningDelegate = self
    backgroundViewController.modalPresentationStyle = .fullScreen
    return backgroundViewController
  }

  func finishLaunch() {
    sessionServices.lockService.locker.screenLocker?.suspendMomentarelyPrivacyShutter()

    self.sessionServices.appServices.notificationService.requestUserAuthorization()
    self.lockCoordinator.start()
    self.accessControlCoordinator.start()
    self.modalCoordinator.start()
    self.setupDeepLinking()
    self.lockCoordinator.showBiometryChangeIfNeeded()
    self.showVersionValidityAlertIfNeeded()
    self.configure2FAEnforcement()
    self.sessionServices.lockService.locker.didLoadSession()
  }
}

extension ConnectedCoordinator: UIViewControllerTransitioningDelegate {
  func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning?
  {
    return LockAnimator(isOpening: true)
  }

  func animationController(
    forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {

    return LockAnimator(isOpening: false)
  }
}

extension ConnectedCoordinator {
  func syncStatusDidChange(to newStatus: SyncService.SyncStatus) {
    switch newStatus {
    case .error(SyncError.unknownUserDevice):
      self.logoutHandler?.logoutAndPerform(action: .deleteCurrentSessionLocalData)
    default:
      break
    }
  }
}

extension ConnectedCoordinator {
  private func showVersionValidityAlertIfNeeded() {
    sessionServices.appServices.versionValidityService.shouldShowAlertPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        guard let self = self else { return }
        let alertDismissed = {
          self.sessionServices.appServices.versionValidityService.messageDismissed(for: status)
        }
        guard
          let alert = VersionValidityAlert(status: status, alertDismissed: alertDismissed)
            .makeAlert()
        else {
          return
        }

        self.window.rootViewController?.present(alert, animated: true)
        self.sessionServices.appServices.versionValidityService.messageShown(for: status)
      }.store(in: &subscriptions)
  }
}

extension AppTrackingTransparencyService {
  fileprivate convenience init(sessionServices: SessionServicesContainer) {
    self.init(
      authenticatedABTestingService: sessionServices.authenticatedABTestingService,
      logger: sessionServices.appServices.rootLogger[.appTrackingTransparency])
  }
}
