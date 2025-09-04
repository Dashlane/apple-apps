import Combine
import CoreCategorizer
import CoreMainMenu
import CorePersonalData
import CoreSession
import CoreSync
import DesignSystem
import LogFoundation
import LoginKit
import Lottie
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit
import VaultKit

final class ConnectedCoordinator: NSObject, Coordinator, SubcoordinatorOwner {
  let sessionServices: SessionServicesContainer
  let window: UIWindow
  let appRootNavigationViewController: UINavigationController
  var subcoordinator: Coordinator?
  let lockCoordinator: LockCoordinator
  let modalCoordinator: ModalCoordinator
  let onboardingService: OnboardingService
  private let appTrackingTransparencyService: AppTrackingTransparencyService
  var subscriptions = Set<AnyCancellable>()
  private weak var logoutHandler: SessionLifeCycleHandler?
  private var syncStatusSubscription: AnyCancellable?

  private let mainMenuHandler: SessionMainMenuHandler

  init(
    sessionServices: SessionServicesContainer,
    window: UIWindow,
    appRootNavigationViewController: UINavigationController,
    logoutHandler: SessionLifeCycleHandler,
    applicationMainMenuHandler: ApplicationMainMenuHandler
  ) {
    self.window = window
    self.lockCoordinator = LockCoordinator(
      sessionServices: sessionServices,
      baseWindow: window)
    self.sessionServices = sessionServices
    self.modalCoordinator = .init(baseWindow: window, sessionServices: sessionServices)
    self.onboardingService = sessionServices.onboardingService
    self.logoutHandler = logoutHandler
    self.appRootNavigationViewController = appRootNavigationViewController

    let logger = sessionServices.appServices.rootLogger
    self.appTrackingTransparencyService = AppTrackingTransparencyService(
      logger: logger[.appTrackingTransparency])
    self.mainMenuHandler = SessionMainMenuHandler(
      applicationHandler: applicationMainMenuHandler,
      syncService: sessionServices.syncService,
      bridge: MainMenuBarBridge.shared,
      logger: logger)
  }

  func start() {
    LoadingOverlayWindowCoordinator.shared.dismiss()

    configureAppearance()

    showStartingView()

    syncStatusSubscription = sessionServices.syncService.$syncStatus
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        self?.syncStatusDidChange(to: status)
      }
  }

  private func configureAppearance() {
    UITableView.appearance().backgroundColor = UIColor.ds.background.default
    UITableView.appearance().sectionHeaderTopPadding = 0.0
  }

  func dismiss(completion: @escaping () -> Void) {
    mainMenuHandler.unload()
    lockCoordinator.dismiss()
    syncStatusSubscription?.cancel()
    completion()
  }

  private func showStartingView() {
    if let biometry = Device.biometryType, onboardingService.shouldShowFastLocalSetupForFirstLogin {
      showFastLocalSetup(for: biometry)
    } else if Device.is(.mac), onboardingService.shouldShowFastLocalSetupForFirstLogin {
      showFastLocalSetupForRememberMasterPassword()
    } else {
      showConnectedView()
    }
  }

  func showConnectedView() {
    let newRootViewController = makeConnectedViewController()

    Task {
      if case .accountCreation = self.sessionServices.loadingContext {
        await self.appTrackingTransparencyService.requestAuthorization()
      } else {
        await self.sessionServices.appServices.notificationService.requestUserAuthorization()
      }

      self.window.rootViewController = newRootViewController
      if self.onboardingService.shouldShowBiometricsOrPinOnboardingForSSO {
        self.showBiometricsOrPinOnboarding()
      } else {
        self.finishLaunch()
      }
    }
  }

  func makeConnectedViewController() -> UIViewController {
    let services = self.sessionServices
    let model = services.makeConnectedRootViewModel()
    let lockPlaceholder = Image(uiImage: window.imageFromLayer())
    let view = ConnectedRootView(model: model, onLoginLockPlaceholder: lockPlaceholder)

    return MainMenuHandlerHostingViewController(rootView: view)
  }

  func finishLaunch() {
    self.lockCoordinator.start()
    self.modalCoordinator.start()
    self.setupDeepLinking()
    self.lockCoordinator.showBiometryChangeIfNeeded()
    self.showVersionValidityAlertIfNeeded()
    self.configure2FAEnforcement()
    self.sessionServices.lockService.locker.didLoadSession()

    appRootNavigationViewController.popToRootViewController(animated: false)
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
        guard let self else { return }
        let versionValidityService = self.sessionServices.appServices.versionValidityService

        let alertDismissed = { versionValidityService.messageDismissed(for: status) }

        guard
          let alert = VersionValidityAlert(status: status, alertDismissed: alertDismissed)
            .makeAlert()
        else {
          return
        }

        self.window.rootViewController?.present(alert, animated: true)
        versionValidityService.messageShown(for: status)
      }.store(in: &subscriptions)
  }
}
