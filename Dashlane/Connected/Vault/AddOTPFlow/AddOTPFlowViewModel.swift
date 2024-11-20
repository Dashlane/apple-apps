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
class AddOTPFlowViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {

  enum FailureAction {
    case tryAgain
    case cancel
  }

  enum Step {
    case intro
    case addOTPManually(Credential?)
    case scanQRCode
    case success(mode: AddOTPSuccessView.Mode)
    case chooseCredential(viewModel: MatchingCredentialListViewModel)
    case addCredential(Credential)
    case failure(FailureReason)

    enum FailureReason {
      case dashlaneSecretDetected
      case badSecretKey(String)
      case badOTP
      case multipleMatchingCredentials(String)
    }
  }

  enum Mode {
    case credentialPrefilled(Credential)
    case newCredential
  }

  @Published
  var steps: [Step] = [.intro]

  let mode: Mode

  var credential: Credential? {
    switch mode {
    case let .credentialPrefilled(credential):
      return credential
    default:
      return nil
    }
  }

  private var otpConfiguration: OTPConfiguration?
  private let completion: () -> Void

  let dismissPublisher = PassthroughSubject<Void, Never>()
  let activityReporter: ActivityReporterProtocol
  let vaultItemsStore: VaultItemsStore
  let vaultItemDatabase: VaultItemDatabaseProtocol
  let matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory
  let addOTPManuallyFlowViewModelFactory: AddOTPManuallyFlowViewModel.Factory
  let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory

  init(
    otpURL: URL? = nil,
    activityReporter: ActivityReporterProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory,
    addOTPManuallyFlowViewModelFactory: AddOTPManuallyFlowViewModel.Factory,
    credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
    mode: AddOTPFlowViewModel.Mode,
    completion: @escaping () -> Void
  ) {
    self.activityReporter = activityReporter
    self.mode = mode
    self.vaultItemsStore = vaultItemsStore
    self.vaultItemDatabase = vaultItemDatabase
    self.addOTPManuallyFlowViewModelFactory = addOTPManuallyFlowViewModelFactory
    self.matchingCredentialListViewModelFactory = matchingCredentialListViewModelFactory
    self.credentialDetailViewModelFactory = credentialDetailViewModelFactory
    self.completion = completion
    guard let otp = otpURL?.absoluteString,
      let info = try? OTPConfiguration(otpString: otp, supportDashlane2FA: false)
    else {
      handleScanCompletion(.failure(OTPUrlParserError.incorrectFormat))
      return
    }
    handleScanCompletion(.success(info))
  }

  func introViewCompletionHandler(action: AddOTPIntroView.Action) {
    switch action {
    case .cancel:
      completeFlow()
    case .scanQRCode:
      add(.scanQRCode)
      logOTPAdditionStarted(for: .qrCode, to: credential)
    case let .enterToken(credential):
      add(.addOTPManually(credential))
      logOTPAdditionStarted(for: .textCode, to: credential)
    }
  }

  func add(_ navigationStep: Step) {
    Task { @MainActor in
      self.steps.append(navigationStep)
    }
  }

  func makeAddOTPManuallyFlowViewModel(credential: Credential?) -> AddOTPManuallyFlowViewModel {
    addOTPManuallyFlowViewModelFactory.make(credential: credential) { [weak self] completion in
      guard let self = self else { return }
      switch completion {
      case .completed:
        self.completeFlow()
      case let .failure(reason):
        self.add(.failure(reason))
      }
    }
  }

  func handleScanCompletion(_ result: Result<OTPConfiguration, Error>) {
    switch result {
    case .success(let configuration):
      self.otpConfiguration = configuration
      if var credential = credential {
        add(.success(mode: .credentialPrefilled(credential)))
        logOTPAdded(configuration, to: credential, by: .qrCode)
        credential.otpURL = configuration.otpURL
        _ = try? vaultItemDatabase.save(credential)
      } else {
        checkDatabase(for: configuration)
      }
    case .failure(let failure):
      self.add(.failure(.badOTP))
    }

  }

  func checkDatabase(for configuration: OTPConfiguration) {
    let matchingCredentials = vaultItemsStore.credentials.withoutOTP().matchingCredentials(
      for: configuration)
    switch matchingCredentials.count {
    case 0:
      add(.success(mode: .promptToEnterCredential(configuration: configuration)))
    case 1:
      guard let credential = matchingCredentials.first else {
        return
      }
      link(configuration: configuration, to: credential)
    default:
      add(
        .chooseCredential(
          viewModel: matchingCredentialListViewModelFactory.make(
            website: configuration.issuerOrTitle,
            matchingCredentials: matchingCredentials
          ) { [weak self] action in
            self?.handleMatchingCredentialCompletion(action: action, for: configuration)
          }))
    }
  }

  func handleMatchingCredentialCompletion(
    action: MatchingCredentialListViewModel.Completion, for configuration: OTPConfiguration
  ) {
    switch action {
    case .createCredential:
      addCredentialStep(for: configuration)
    case let .linkToCredential(credential):
      link(configuration: configuration, to: credential)
    }
  }

  func link(configuration: OTPConfiguration, to credential: Credential) {
    var editedCredential = credential
    add(.success(mode: .credentialPrefilled(editedCredential)))
    editedCredential.otpURL = configuration.otpURL
    _ = try? vaultItemDatabase.save(editedCredential)
  }

  func handleSuccessCompletion(for mode: AddOTPSuccessView.Mode) {
    switch mode {
    case let .promptToEnterCredential(configuration):
      addCredentialStep(for: configuration)
    case .credentialPrefilled:
      completeFlow()
    }
  }

  func addCredentialStep(for configuration: OTPConfiguration) {
    guard case let .newCredential = mode else {
      assertionFailure("We should be in `Mode.addCredential`")
      return
    }

    let credential = Credential(OTPInfo(configuration: configuration))
    add(.addCredential(credential))
  }

  func completeFlow() {
    completion()
    dismissPublisher.send()
  }

  func handleFailureViewCompletion(_ action: FailureAction) {
    switch action {
    case .tryAgain:
      steps = [.intro]
    case .cancel:
      completeFlow()
    }
  }
}

extension Array where Element == Credential {

  func withoutOTP() -> Self {
    self.filter { $0.otpURL == nil }
  }

  func matchingCredentials(for otpConfiguration: OTPConfiguration) -> Self {
    let matchingDomain = self.matchingCredentials(forDomain: otpConfiguration.issuerOrTitle)
    guard matchingDomain.count > 1 else {
      return matchingDomain
    }

    let matchingLogin = matchingDomain.filterOnLogin(otpConfiguration.login)
    guard !matchingLogin.isEmpty else {
      return matchingDomain
    }
    return matchingLogin
  }

  func filterOnLogin(_ login: String) -> Self {
    return self.filter { $0.login == login || $0.email == login }
  }
}

extension AddOTPFlowViewModel {
  func makeCredentialDetailViewModel(credential: Credential) -> CredentialDetailViewModel {
    credentialDetailViewModelFactory.make(
      item: credential, mode: .adding(prefilled: false), origin: .adding
    ) { [weak self] in
      self?.completeFlow()
    }
  }
}

extension AddOTPFlowViewModel {
  static var mock: AddOTPFlowViewModel {
    return AddOTPFlowViewModel(
      activityReporter: .mock,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      matchingCredentialListViewModelFactory: .init {
        .mock(website: $0, matchingCredentials: $1, completion: $2)
      },
      addOTPManuallyFlowViewModelFactory: .init { _, _ in .mock },
      credentialDetailViewModelFactory: .init { _, _, _, _, _, _ in .mock },
      mode: AddOTPFlowViewModel.Mode.credentialPrefilled(PersonalDataMock.Credentials.github),
      completion: {}
    )
  }
}

extension ChooseWebsiteViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {}
extension PlaceholderWebsiteViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {}
extension AddLoginDetailsViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {}
