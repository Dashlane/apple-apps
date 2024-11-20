import AuthenticationServices
import AutofillKit
import CoreFeature
import CorePremium
import CoreUserTracking
import DomainParser
import Foundation
import PremiumKit
import VaultKit

@MainActor
class HomeFlowViewModel: ObservableObject, SessionServicesInjecting {

  @Published
  var showOnlyMatchingCredentials: Bool = true

  @Published
  var selection: CredentialSelection?

  @Published
  var vaultState: VaultState = .default

  var visitedWebsite: String?
  let completion: (CredentialSelection?) -> Void

  let sessionActivityReporter: ActivityReporterProtocol
  let request: CredentialsListRequest
  let environmentModelFactory: AutofillConnectedEnvironmentModel.Factory

  private let credentialListViewModelFactory: CredentialListViewModel.Factory

  init(
    credentialListViewModelFactory: CredentialListViewModel.Factory,
    sessionActivityReporter: ActivityReporterProtocol,
    vaultStateService: VaultStateServiceProtocol,
    domainParser: DomainParserProtocol,
    request: CredentialsListRequest,
    environmentModelFactory: AutofillConnectedEnvironmentModel.Factory,
    completion: @escaping (CredentialSelection?) -> Void
  ) {
    self.completion = completion
    self.credentialListViewModelFactory = credentialListViewModelFactory
    self.environmentModelFactory = environmentModelFactory
    self.sessionActivityReporter = sessionActivityReporter
    self.request = request
    if let host = request.services.last?.host {
      let domain = domainParser.parse(host: host)?.domain
      self.visitedWebsite = domain
    }

    vaultStateService
      .vaultStatePublisher()
      .assign(to: &$vaultState)
  }

  func cancel() {
    let event = UserEvent.AutofillDismiss(dismissType: .closeCross)
    sessionActivityReporter.report(event)
    let website = visitedWebsite ?? ""
    sessionActivityReporter.report(
      AnonymousEvent.AutofillDismiss(
        dismissType: .closeCross,
        domain: website.hashedDomainForLogs(),
        isNativeApp: true))
    completion(nil)
  }

  func onAppear() {
    sessionActivityReporter.reportPageShown(.autofillExplorePasswords)
  }

  func makeCredentialListViewModel() -> CredentialListViewModel {
    credentialListViewModelFactory.make(
      visitedWebsite: visitedWebsite,
      request: request,
      completion: completion)
  }
}
