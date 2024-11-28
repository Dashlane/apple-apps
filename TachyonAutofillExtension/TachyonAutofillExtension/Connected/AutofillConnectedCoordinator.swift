import AuthenticationServices
import AutofillKit
import Combine
import CoreData
import CoreKeychain
import CorePersonalData
import CoreUserTracking
import Logger
import LoginKit
import TOTPGenerator
import UIComponents
import UIDelight
import VaultKit

@MainActor
class AutofillConnectedCoordinator: Coordinator, SubcoordinatorOwner {

  let appServices: AppServicesContainer
  let context: ASCredentialProviderExtensionContext
  let sessionServices: SessionServicesContainer
  unowned var rootNavigationController: DashlaneNavigationController
  var subcoordinator: Coordinator?
  let request: CredentialsListRequest
  var database: ApplicationDatabase {
    return sessionServices.database
  }
  let loginKitServices: LoginKitServicesContainer
  let autofillProvider: AutofillProvider

  init(
    hasUserBeenVerified: Bool,
    sessionServicesContainer: SessionServicesContainer,
    appServicesContainer: AppServicesContainer,
    context: ASCredentialProviderExtensionContext,
    rootNavigationController: DashlaneNavigationController,
    request: CredentialsListRequest
  ) {
    self.appServices = appServicesContainer
    self.context = context
    self.sessionServices = sessionServicesContainer
    self.rootNavigationController = rootNavigationController
    self.loginKitServices = appServices.makeLoginKitServicesContainer()
    self.request = request
    let notificationSender = OTPNotificationSender(
      userSettings: sessionServicesContainer.userSettings,
      localNotificationService: LocalNotificationService())

    self.autofillProvider = AutofillProvider(
      hasUserBeenVerified: hasUserBeenVerified,
      database: sessionServicesContainer.database,
      applicationReporter: appServicesContainer.activityReporter,
      sessionReporter: sessionServicesContainer.activityReporter,
      userSpacesService: sessionServices.premiumStatusServicesSuit.userSpacesService,
      autofillService: sessionServices.autofillService,
      otpNotificationSender: { notificationSender.send(for: $0) },
      context: context)

    sessionServicesContainer
      .vaultStateService
      .vaultStatePublisher()
      .filter { $0 == .frozen }
      .receive(on: DispatchQueue.main)
      .sinkOnce { _ in
        self.appServices.deeplinkingService.handle(.frozenAccount)
      }
  }

  @MainActor
  func prepareCredentialList(context: ASCredentialProviderExtensionContext) {
    configureAppearance()
    startListCoordinator(for: request, context: context)
  }

  private func configureAppearance() {
    UITableView.appearance().backgroundColor = .ds.background.default
    UITableViewCell.appearance().backgroundColor = .ds.container.agnostic.neutral.supershy
    UITableView.appearance().tableFooterView = UIView()
    UITableView.appearance().sectionHeaderTopPadding = 0.0
  }

  @MainActor
  private func startListCoordinator(
    for request: CredentialsListRequest, context: ASCredentialProviderExtensionContext
  ) {

    let model = sessionServices.makeHomeFlowViewModel(request: request) { [weak self] in
      self?.didSelect($0)
    }
    let view = CredentialProviderHomeFlow(model: model)
    self.rootNavigationController.setRootNavigation(view, barStyle: .hidden(), animated: true)
  }

  func didSelect(_ credentialSelection: CredentialSelection?) {
    guard let credentialSelection else {
      context.cancelRequest(withError: ASExtensionError.userCanceled.nsError)
      return
    }

    switch credentialSelection.credential {
    case let .credential(credential):
      autofillProvider.autofillPasswordCredential(
        for: credential, on: credentialSelection.visitedWebsite)
    case let .passkey(passkey):
      if #available(iOS 17.0, *) {
        Task {
          guard case let .servicesAndPasskey(_, passkeyAssertionRequest) = request else {
            assertionFailure("Should have had a passkey assertion")
            context.cancelRequest(withError: ASExtensionError.failed.nsError)
            return
          }
          do {
            try await autofillProvider.autofill(passkey, for: passkeyAssertionRequest)
          } catch {
            context.cancelRequest(withError: ASExtensionError.failed.nsError)
          }
        }
      }
    }

  }

  func start() {}

  func logLogin() {
    if let performanceLogInfo = sessionServices.appServices.loginMetricsReporter
      .getPerformanceLogInfo(.login)
    {
      sessionServices.activityReporter.report(
        performanceLogInfo.performanceUserEvent(for: .timeToLoadAutofill))
      sessionServices.appServices.loginMetricsReporter.resetTimer(.login)
    }
  }
}
