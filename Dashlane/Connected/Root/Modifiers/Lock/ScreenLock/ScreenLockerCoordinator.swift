import Combine
import Foundation
import LoginKit
import SwiftUI
import UIComponents
import UIDelight
import UIKit

class ScreenLockerCoordinator: NSObject, SubcoordinatorOwner {

  struct ModalLockSession {
    let window: UIWindow
    let animationOrchestrator: ScreenLockAnimationOrchestrator
  }

  private let screenLocker: ScreenLocker
  let mainWindow: UIWindow
  private var currentLockSession: ModalLockSession?
  private var cancellables = Set<AnyCancellable>()
  private var lastLock: ScreenLocker.Lock?
  let sessionServices: SessionServicesContainer

  private var showBiometryChangeIfNeeded: () -> Void
  var subcoordinator: Coordinator?

  init(
    screenLocker: ScreenLocker,
    sessionServices: SessionServicesContainer,
    mainWindow: UIWindow,
    showBiometryChangeIfNeeded: @escaping () -> Void
  ) {
    self.screenLocker = screenLocker
    self.sessionServices = sessionServices
    self.mainWindow = mainWindow
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
          self.startLockSession()
        } else {
          if case .privacyShutter = self.lastLock {
            closeLockSession()
          } else {
            self.currentLockSession?.animationOrchestrator.perform(.unlock) { [weak self] in
              self?.closeLockSession()
            }
          }
        }
      }.store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      .sink { [weak self] _ in
        self?.lockAfterAppBecomeActive()
      }.store(in: &cancellables)
  }

  func dismiss() {
    clearLockSession()

    cancellables.forEach {
      $0.cancel()
    }
  }

  public func lockAfterAppBecomeActive() {
    if let lock = screenLocker.lock, case ScreenLocker.Lock.secure = lock {
      self.startLockSession()
    }
  }

  private func startLockSession() {
    guard currentLockSession == nil else {
      return
    }

    let modalWindow = makeLockWindow()
    let animationOrchestrator = ScreenLockAnimationOrchestrator(
      lockWindow: modalWindow,
      mainWindow: mainWindow
    )

    let lockViewModel = sessionServices.viewModelFactory.makeLockViewModel(locker: screenLocker) {
      [weak self] in
      self?.launchMasterPasswordChanger()
    }
    let lockView = LockView(viewModel: lockViewModel)
      .modifier(ScreenLockAnimationOverlayModifier(animationOrchestrator: animationOrchestrator))

    let uiHostingController = UIHostingController(rootView: lockView)
    modalWindow.rootViewController = uiHostingController
    modalWindow.makeKeyAndVisible()
    modalWindow.isHidden = false

    currentLockSession = ModalLockSession(
      window: modalWindow, animationOrchestrator: animationOrchestrator)
  }

  private func closeLockSession() {
    guard clearLockSession() else {
      return
    }

    showBiometryChangeIfNeeded()
  }

  @discardableResult
  private func clearLockSession() -> Bool {
    guard let modalSession = currentLockSession else {
      return false
    }
    self.currentLockSession = nil
    modalSession.window.isHidden = true

    return true
  }

}

extension ScreenLockerCoordinator {
  private func makeLockWindow() -> UIWindow {
    let modalWindow: UIWindow
    if let scene = mainWindow.windowScene {
      modalWindow = UIWindow(windowScene: scene)
    } else {
      #if os(visionOS)
        fatalError("Deal with it")
      #else
        modalWindow = UIWindow(frame: UIScreen.main.bounds)
      #endif
    }

    modalWindow.backgroundColor = .black
    modalWindow.windowLevel = .statusBar + 1

    return modalWindow
  }
}

extension ScreenLockerCoordinator {
  func launchMasterPasswordChanger() {
    guard let lockViewController = currentLockSession?.window.rootViewController else {
      return
    }

    let viewModel = sessionServices.makeMP2MPAccountMigrationViewModel(
      migrationContext: .accountRecovery
    ) { [weak self, weak lockViewController] result in
      lockViewController?.presentedViewController?.dismiss(animated: true)

      guard let self, case .success(let session) = result else {
        return
      }

      self.sessionServices
        .appServices
        .sessionLifeCycleHandler?
        .logoutAndPerform(
          action: .startNewSession(session, reason: .masterPasswordChanged)
        )
    }

    let view = MP2MPAccountMigrationFlowView(viewModel: viewModel)
    let viewController = UIHostingController(rootView: view.dashlaneDefaultStyle())
    viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
    lockViewController.present(viewController, animated: true)
  }
}
