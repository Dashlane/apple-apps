import AuthenticatorKit
import Combine
import CoreNetworking
import CorePersonalData
import CoreSync
import CoreUserTracking
import DashTypes
import Foundation
import IconLibrary
import TOTPGenerator
import VaultKit

@MainActor
class AddOTPManuallyFlowViewModel: ObservableObject, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  enum Step {
    case enterToken(Credential)
    case manuallyChooseWebsite
    case enterLoginDetails(website: String, Credential?)
    case chooseCredential(website: String, matchingCredentials: [Credential])
    case addCredential(Credential, OTPConfiguration)
    case success(mode: AddOTPSuccessView.Mode, configuration: OTPConfiguration)
  }

  enum Completion {
    case completed(OTPConfiguration)
    case failure(AddOTPFlowViewModel.Step.FailureReason)
  }

  @Published
  var steps: [Step] = []

  private let completion: (Completion) -> Void

  let dismissPublisher = PassthroughSubject<Void, Never>()
  let vaultItemsStore: VaultItemsStore
  let vaultItemDatabase: VaultItemDatabaseProtocol
  let matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory
  let chooseWebsiteViewModelFactory: ChooseWebsiteViewModel.Factory
  let addLoginDetailsViewModelFactory: AddLoginDetailsViewModel.Factory
  let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory

  init(
    credential: Credential?,
    vaultItemsStore: VaultItemsStore,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory,
    chooseWebsiteViewModelFactory: ChooseWebsiteViewModel.Factory,
    addLoginDetailsViewModelFactory: AddLoginDetailsViewModel.Factory,
    credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
    completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void
  ) {
    self.chooseWebsiteViewModelFactory = chooseWebsiteViewModelFactory
    self.vaultItemsStore = vaultItemsStore
    self.vaultItemDatabase = vaultItemDatabase
    self.addLoginDetailsViewModelFactory = addLoginDetailsViewModelFactory
    self.credentialDetailViewModelFactory = credentialDetailViewModelFactory
    self.matchingCredentialListViewModelFactory = matchingCredentialListViewModelFactory
    self.completion = completion
    if let credential = credential {
      add(.enterToken(credential))
    } else {
      add(.manuallyChooseWebsite)
    }
  }

  func makeChooseWebsiteViewModel() -> ChooseWebsiteViewModel {
    chooseWebsiteViewModelFactory.make { [weak self] website in
      guard let self = self else { return }
      Task {

        guard !website.lowercased().contains("dashlane") else {
          await MainActor.run {
            self.completion(.failure(.dashlaneSecretDetected))
          }
          return
        }

        let matchingCredentials = self.vaultItemsStore.credentials
          .withoutOTP()
          .matchingCredentials(forDomain: website)
        switch matchingCredentials.count {
        case 0:
          self.add(.enterLoginDetails(website: website, nil))
        case 1:
          guard let credential = matchingCredentials.first else {
            return
          }
          self.add(.enterLoginDetails(website: website, credential))
        default:
          self.add(
            .chooseCredential(
              website: website,
              matchingCredentials: matchingCredentials))
        }
      }
    }
  }

  func add(_ navigationStep: Step) {
    Task {
      await MainActor.run {
        steps.append(navigationStep)
      }
    }
  }

  func handleMatchingCredentialCompletion(
    action: MatchingCredentialListViewModel.Completion, for domain: String
  ) {
    switch action {
    case .createCredential:
      add(.enterLoginDetails(website: domain, nil))
    case let .linkToCredential(credential):
      add(.enterLoginDetails(website: domain, credential))
    }
  }

  func handleSuccessCompletion(for mode: AddOTPSuccessView.Mode, configuration: OTPConfiguration) {
    switch mode {
    case let .promptToEnterCredential(configuration):
      addCredentialStep(for: configuration)
    case .credentialPrefilled:
      self.completion(.completed(configuration))
    }
  }

  func addCredentialStep(for configuration: OTPConfiguration) {
    let credential = Credential(OTPInfo(configuration: configuration))
    add(.addCredential(credential, configuration))
  }
}

extension AddOTPManuallyFlowViewModel {
  static var mock: AddOTPManuallyFlowViewModel {
    .init(
      credential: nil,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      matchingCredentialListViewModelFactory: .init { _, _, _ in .mock() },
      chooseWebsiteViewModelFactory: .init { _ in .mock() },
      addLoginDetailsViewModelFactory: .init { _, _, _, _ in .mock },
      credentialDetailViewModelFactory: .init({ _, _, _, _, _, _ in
        MockVaultConnectedContainer().makeCredentialDetailViewModel(
          item: PersonalDataMock.Credentials.amazon, mode: .adding(prefilled: false))
      }),
      completion: { _ in })
  }
}

extension AddOTPManuallyFlowViewModel {
  func makeAddOTPSecretKeyViewModel(credential: Credential) -> AddOTPSecretViewModel {
    AddOTPSecretViewModel(credential: credential) { [weak self] result in
      guard let self = self else { return }

      switch result {
      case let .success(configuration):
        do {
          let info = try OTPInfo(
            configuration: .init(otpURL: configuration.otpURL, supportDashlane2FA: false))
          var tempCredential = credential
          self.add(
            .success(mode: .credentialPrefilled(credential), configuration: info.configuration))
          tempCredential.otpURL = info.configuration.otpURL
          _ = try? self.vaultItemDatabase.save(tempCredential)
        } catch {
          self.completion(.failure(.badSecretKey(credential.title)))
        }
      case .failure:
        self.completion(.failure(.badSecretKey(credential.title)))
      }
    }
  }

  func makeAddLoginDetailsViewModel(
    website: String,
    credential: Credential?
  ) -> AddLoginDetailsViewModel {
    addLoginDetailsViewModelFactory.make(
      website: website,
      credential: credential,
      supportDashlane2FA: false
    ) { [weak self] otpInfo in
      guard let self = self else { return }
      if let credential = credential {
        var editedCredential = credential
        editedCredential.otpURL = otpInfo.configuration.otpURL
        _ = try? self.vaultItemDatabase.save(editedCredential)
        self.add(
          .success(
            mode: .credentialPrefilled(editedCredential), configuration: otpInfo.configuration))
      } else {
        self.addCredentialStep(for: otpInfo.configuration)
      }
    }
  }

  func makeMatchingCredentialListViewModel(website: String, matchingCredentials: [Credential])
    -> MatchingCredentialListViewModel
  {
    matchingCredentialListViewModelFactory.make(
      website: website,
      matchingCredentials: matchingCredentials
    ) { [weak self] action in
      self?.handleMatchingCredentialCompletion(action: action, for: website)
    }
  }

  func makeCredentialDetailViewModel(credential: Credential, configuration: OTPConfiguration)
    -> CredentialDetailViewModel
  {
    credentialDetailViewModelFactory.make(
      item: credential, mode: .adding(prefilled: false), origin: .adding
    ) { [weak self] in
      self?.completion(.completed(configuration))
    }
  }
}
