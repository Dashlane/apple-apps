import AuthenticationServices
import AutofillKit
import CoreFeature
import CorePremium
import CoreSettings
import CoreTypes
import DomainParser
import Foundation
import LoginKit
import PremiumKit
import UserTrackingFoundation
import VaultKit

@MainActor
class CredentialProviderFlowModel: ObservableObject, SessionServicesInjecting {
  enum Step: Hashable {
    case list
    case frozen
    case addCredentialPassword
  }

  @Published var steps: [Step] = [.list]
  @Published var showOnlyMatchingCredentials: Bool = true
  @Published var selection: CredentialSelection?

  var visitedWebsite: String?

  let request: CredentialsListRequest
  let environmentModelFactory: AutofillConnectedEnvironmentModel.Factory

  private let userSettings: UserSettings
  private let sessionActivityReporter: ActivityReporterProtocol
  private let autofillProvider: AutofillProvider
  private let credentialListViewModelFactory: CredentialListViewModel.Factory
  private let addCredentialViewModelFactory: AddCredentialViewModel.Factory

  init(
    autofillProvider: AutofillProvider,
    request: CredentialsListRequest,
    sessionActivityReporter: ActivityReporterProtocol,
    vaultStateService: VaultStateServiceProtocol,
    domainParser: DomainParserProtocol,
    userSettings: UserSettings,
    deeplinkingService: DeepLinkingServiceProtocol,
    credentialListViewModelFactory: CredentialListViewModel.Factory,
    addCredentialViewModelFactory: AddCredentialViewModel.Factory,
    environmentModelFactory: AutofillConnectedEnvironmentModel.Factory
  ) {
    self.credentialListViewModelFactory = credentialListViewModelFactory
    self.addCredentialViewModelFactory = addCredentialViewModelFactory
    self.environmentModelFactory = environmentModelFactory
    self.request = request
    self.userSettings = userSettings
    self.sessionActivityReporter = sessionActivityReporter
    self.autofillProvider = autofillProvider

    if let host = request.servicesIdentifiers.last?.host {
      let domain = domainParser.parse(host: host)?.domain
      self.visitedWebsite = domain
    }

    vaultStateService
      .vaultStatePublisher()
      .filter { $0 == .frozen }
      .removeDuplicates()
      .map { _ in [.frozen] }
      .receive(on: DispatchQueue.main)
      .assign(to: &$steps)
  }

  private func didSelect(_ credentialSelection: CredentialSelection?) async {
    guard let credentialSelection else {
      autofillProvider.cancel()
      return
    }

    switch credentialSelection.credential {
    case let .password(credential):
      autofillProvider.autofillPassword(with: credential, on: credentialSelection.visitedWebsite)

    case let .otp(credential):
      if #available(iOS 18.0, visionOS 2.0, *) {
        await autofillProvider.autofillOTPCredential(with: credential)
      }
    case let .passkey(passkey):
      if #available(iOS 17.0, *) {
        guard case let .passkeysAndPasswords(passkeyAssertionRequest) = request.type else {
          assertionFailure("Should have had a passkey assertion")
          return
        }

        await autofillProvider.autofill(passkey, for: passkeyAssertionRequest)
      }
    }
  }
}

extension CredentialProviderFlowModel {
  func makeCredentialListViewModel() -> CredentialListViewModel {
    credentialListViewModelFactory.make(visitedWebsite: visitedWebsite, request: request) {
      [weak self] selection in
      guard let self = self else {
        return
      }

      Task {
        await self.didSelect(selection)
      }
    }
  }

  func makeAddCredentialPasswordViewModel() -> AddCredentialViewModel {
    addCredentialViewModelFactory.make(
      visitedWebsite: visitedWebsite,
      didFinish: { [weak self] credential in
        guard let self = self else {
          return
        }

        let selection = CredentialSelection(
          credential: .password(credential), visitedWebsite: self.visitedWebsite)

        Task {
          await self.didSelect(selection)
        }
      })
  }

}
