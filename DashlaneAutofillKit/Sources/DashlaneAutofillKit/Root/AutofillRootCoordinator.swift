import AuthenticationServices
import AutofillKit
import CoreData
import CorePersonalData
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import LogFoundation
import Logger
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

public protocol CredentialRootViewControllerContainer: UIViewController {
  var rootViewController: UIViewController? { get set }
}

extension CredentialRootViewControllerContainer {
  func setRootView(_ view: some View) {
    rootViewController = UIHostingController(rootView: view.tint(.ds.accentColor))
  }
}

@MainActor
public class AutofillRootCoordinator: Coordinator, SubcoordinatorOwner {

  let context: ASCredentialProviderExtensionContext
  let appServices: AppServicesContainer

  unowned var container: CredentialRootViewControllerContainer!
  public var subcoordinator: Coordinator?
  var inMemoryUserSessionStore: InMemoryUserSessionStore? {
    get {
      InMemoryUserSessionStore.shared
    }
    set {
      InMemoryUserSessionStore.shared = newValue
    }
  }

  var allAppMessages: [AppAutofillExtensionCommunicationCenter.AppMessage] = []

  var logger: Logger {
    appServices.rootLogger[.autofill]
  }

  public init(
    context: ASCredentialProviderExtensionContext, container: CredentialRootViewControllerContainer
  ) async {
    self.appServices = await AppServicesContainer.sharedInstance()
    appServices.appSettings.configure()
    self.context = context
    self.container = container
  }

  public func start() {}

  func cleanPersistedServices() {
    self.inMemoryUserSessionStore = nil
    self.container.rootViewController = nil
  }

  func handleAppExtensionCommunication() {
    let messagesReceived: Set<AppAutofillExtensionCommunicationCenter.AppMessage> = appServices
      .appExtensionCommunication.consumeMessages()

    self.allAppMessages += messagesReceived

    guard let inMemoryUserSessionStore else {
      return
    }

    let shoudClearPersistedSession = messagesReceived.contains { message in
      switch message {
      case .didLogin(inMemoryUserSessionStore.login):
        false
      case .didLogout, .premiumStatusDidUpdate, .didLogin:
        true
      }
    }

    if shoudClearPersistedSession {
      logger.info("Main app requires to logout")
      cleanPersistedServices()
    }
  }

  @MainActor
  func retrieveSessionServicesFromMemory(shouldCheckLock: Bool = true) -> SessionServicesContainer?
  {
    do {
      let container =
        shouldCheckLock
        ? try inMemoryUserSessionStore?.retrieveStoredSession()
        : try inMemoryUserSessionStore?.retrieveStoredSessionIgnoringLock()

      logger.info("has session available in memory: \(container != nil)")
      return container
    } catch let error {
      switch error {
      case .lockedOnExit:
        logger.warning("lock on exit enabled, cannot reuse session")
      case .autoLockDelayReached:
        logger.warning("auto lock, cannot reuse session")
      case .tooOld:
        logger.warning("The session is too old and cannot be reused")
      }

      cleanPersistedServices()
      return nil
    }
  }

  @MainActor
  func retrieveSessionServicesFromMemoryOrPresentLogin() async throws -> (
    SessionServicesContainer, hasAuthenticate: Bool
  ) {
    handleAppExtensionCommunication()

    if let sessionServices = try? self.inMemoryUserSessionStore?.retrieveStoredSession() {
      logger.info("Use session in memory")
      sessionServices.syncService.sync(triggeredBy: .periodic)
      return (sessionServices, false)
    } else {
      logger.info("No session in memory, authenticate")
      let sessionServices = try await authenticateUser()
      return (sessionServices, true)
    }
  }

  @MainActor
  private func authenticateUser() async throws -> SessionServicesContainer {
    let sessionServices = try await withCheckedThrowingContinuation { [weak self] continuation in
      guard let self = self else { return }
      let navigationController = UINavigationController()
      container.rootViewController = navigationController
      let authenticationCoordinator = AuthenticationCoordinator(
        appServices: appServices,
        navigator: navigationController,
        localLoginFlowViewModelFactory: .init(appServices.makeLocalLoginFlowViewModel)
      ) { result in
        continuation.resume(with: result)
      }

      startSubcoordinator(authenticationCoordinator)
    }

    subcoordinator = nil

    logger.info("User Connected and services loaded")

    guard sessionServices.syncService.hasAlreadySync() else {
      throw AuthenticationCoordinator.AuthError.noUserConnected(details: "emptydb")
    }

    return sessionServices
  }

  fileprivate func cancelRequest() {
    context.cancelRequest(withError: NSError(.userCanceled))
  }

  @MainActor
  func displayErrorStateOrCancelRequest(error: Error) async {
    if case let AuthenticationCoordinator.AuthError.noUserConnected(details) = error {
      let view = makeAutofillErrorView(error: .noUserConnected(details: details))
      container.setRootView(view)
    } else if case AuthenticationCoordinator.AuthError.ssoUserWithNoAccountCreated = error {
      let view = makeAutofillErrorView(error: .ssoUserWithNoConvenientLoginMethod)
      container.setRootView(view)
    } else {
      cancelRequest()
    }
  }
}

extension AutofillRootCoordinator {
  fileprivate func makeAutofillErrorView(error: AutofillError) -> AutofillErrorView {
    AutofillErrorView(error: error) { [weak self] action in
      guard let self = self else {
        return
      }

      switch action {
      case .cancel:
        self.cancelRequest()
      }
    }
  }
}
