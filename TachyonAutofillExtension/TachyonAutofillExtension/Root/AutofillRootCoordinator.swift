import AuthenticationServices
import AutofillKit
import CoreData
import CorePersonalData
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import Foundation
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

@MainActor
class AutofillRootCoordinator: Coordinator, SubcoordinatorOwner {

  let context: ASCredentialProviderExtensionContext
  let appServices: AppServicesContainer
  let loginKitServices: LoginKitServicesContainer

  unowned var rootNavigationController: DashlaneNavigationController!
  var subcoordinator: Coordinator?
  var inMemoryUserSessionStore: InMemoryUserSessionStore? {
    get {
      InMemoryUserSessionStore.shared
    }
    set {
      InMemoryUserSessionStore.shared = newValue
    }
  }

  var allAppMessages: [AppExtensionCommunicationCenter.Message] = []

  var logger: Logger {
    appServices.rootLogger[.session]
  }

  init(
    context: ASCredentialProviderExtensionContext, rootViewController: DashlaneNavigationController
  ) {
    self.appServices = AppServicesContainer.sharedInstance
    appServices.appSettings.configure()
    self.context = context
    self.rootNavigationController = rootViewController
    self.loginKitServices = appServices.makeLoginKitServicesContainer()
  }

  func start() {}

  func cleanPersistedServices() {
    self.inMemoryUserSessionStore = nil
  }

  func handleAppExtensionCommunication() {
    let messagesReceived: Set<AppExtensionCommunicationCenter.Message> = appServices
      .appExtensionCommunication.consumeMessages()

    self.allAppMessages += messagesReceived

    guard inMemoryUserSessionStore != nil else {
      return
    }

    if messagesReceived.contains(.userDidLogout)
      || messagesReceived.contains(.premiumStatusDidUpdate)
    {
      logger.info("Main app requires to logout")
      cleanPersistedServices()
    }
  }

  @MainActor
  func retrieveSessionServicesFromMemory() -> SessionServicesContainer? {
    do {
      let container = try inMemoryUserSessionStore?.retrieveStoredSession()
      logger.warning("has session available in memory: \(container != nil)")
      return container
    } catch let error {
      switch error {
      case InMemoryUserSessionStore.RetrieveSessionError.lockedOnExit:
        logger.warning("lock on exit enabled, cannot reuse session")

      case InMemoryUserSessionStore.RetrieveSessionError.autoLockDelayReached:
        logger.warning("auto lock, cannot reuse session")

      default:
        logger.error("session is unreachable, cannot reuse session")
      }

      cleanPersistedServices()
      return nil
    }
  }

  @MainActor
  func retrieveConnectedCoordinator(for request: CredentialsListRequest) async throws
    -> AutofillConnectedCoordinator
  {
    logger.info("try retrieve ConnectedCoordinator / List UI")

    let (sessionServices, hasAuthenticate) =
      try await retrieveSessionServicesFromMemoryOrPresentLogin()

    let coordinator = makeConnectedCoordinator(
      with: sessionServices,
      request: request,
      hasUserBeenVerified: hasAuthenticate)
    return coordinator
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

      let authenticationCoordinator = AuthenticationCoordinator(
        appServices: appServices,
        navigator: rootNavigationController,
        localLoginFlowViewModelFactory: .init(loginKitServices.makeLocalLoginFlowViewModel)
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

  func makeConnectedCoordinator(
    with sessionServices: SessionServicesContainer,
    request: CredentialsListRequest,
    hasUserBeenVerified: Bool
  ) -> AutofillConnectedCoordinator {
    let connectedCoordinator = AutofillConnectedCoordinator(
      hasUserBeenVerified: hasUserBeenVerified,
      sessionServicesContainer: sessionServices,
      appServicesContainer: appServices,
      context: context,
      rootNavigationController: rootNavigationController,
      request: request)
    self.subcoordinator = connectedCoordinator
    return connectedCoordinator
  }

  fileprivate func cancelRequest() {
    context.cancelRequest(withError: ASExtensionError.userCanceled.nsError)
  }

  @MainActor
  func displayErrorStateOrCancelRequest(error: Error) async {
    if case let AuthenticationCoordinator.AuthError.noUserConnected(details) = error {
      let view = makeAutofillErrorView(error: .noUserConnected(details: details))
      rootNavigationController.viewControllers = [UIHostingController(rootView: view)]
    } else if case AuthenticationCoordinator.AuthError.ssoUserWithNoAccountCreated = error {
      let view = makeAutofillErrorView(error: .ssoUserWithNoConvenientLoginMethod)
      rootNavigationController.viewControllers = [UIHostingController(rootView: view)]
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
