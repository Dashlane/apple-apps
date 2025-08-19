import AuthenticatorKit
import Combine
import CorePersonalData
import CoreTypes
import Foundation
import IconLibrary
import UserTrackingFoundation
import VaultKit

@MainActor
class AuthenticatorToolFlowViewModel: ObservableObject, SessionServicesInjecting {
  enum Step: Equatable {
    case otpList
    case explorer(isFirstView: Bool)
  }

  @Published
  var steps: [Step] = []

  @Published
  var lastCodeAdded: OTPInfo?

  private var selectedCredential: Credential?

  @Published
  var expandedToken: OTPInfo?

  @Published
  var presentAdd2FAFlow: Bool = false

  private var otpURL: URL?
  private let iconService: IconServiceProtocol
  private let deepLinkingService: DeepLinkingServiceProtocol
  private let otpDatabaseService: AuthenticatorDatabaseServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let otpExplorerViewModelFactory: OTPExplorerViewModel.Factory
  private let otpTokenListViewModelFactory: OTPTokenListViewModel.Factory
  private let supportedDomainsRepository: OTPSupportedDomainsRepository
  private let addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory
  private var cancellables = Set<AnyCancellable>()
  let credentialDetailViewModelProvider: CredentialDetailViewModel.Factory

  init(
    activityReporter: ActivityReporterProtocol,
    deepLinkingService: DeepLinkingServiceProtocol,
    otpDatabaseService: AuthenticatorDatabaseServiceProtocol,
    iconService: IconServiceProtocol,
    otpExplorerViewModelFactory: OTPExplorerViewModel.Factory,
    otpTokenListViewModelFactory: OTPTokenListViewModel.Factory,
    credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
    addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory
  ) {
    self.activityReporter = activityReporter
    self.otpDatabaseService = otpDatabaseService
    self.supportedDomainsRepository = OTPSupportedDomainsRepository()
    self.deepLinkingService = deepLinkingService
    self.otpExplorerViewModelFactory = otpExplorerViewModelFactory
    self.otpTokenListViewModelFactory = otpTokenListViewModelFactory
    self.credentialDetailViewModelProvider = credentialDetailViewModelFactory
    self.addOTPFlowViewModelFactory = addOTPFlowViewModelFactory
    self.iconService = iconService
    start()
  }

  func start() {
    otpDatabaseService.isLoadedPublisher.filter { $0 }.sink { [weak self] _ in
      guard let self = self else {
        return
      }
      let hasOTPToken = !self.otpDatabaseService.codes.isEmpty

      if self.steps.isEmpty {
        self.lastCodeAdded = self.otpDatabaseService.codes.first
      }
      let newFirstStep: Step = hasOTPToken ? .otpList : .explorer(isFirstView: true)
      if newFirstStep != self.steps.first {
        self.replaceFirstStep(by: newFirstStep)
      }
    }.store(in: &cancellables)

    deepLinkingService.deepLinkPublisher.sink { [weak self] deeplink in
      guard let self = self else {
        return
      }
      switch deeplink {
      case let .tool(toolDeeplink, origin):
        guard case let .authenticator(url) = toolDeeplink else {
          return
        }
        self.otpURL = url
        presentAdd2FAFlow = true
      default: break
      }
    }.store(in: &cancellables)
  }

  func makeExplorerViewModel() -> OTPExplorerViewModel {
    return otpExplorerViewModelFactory.make(
      otpSupportedDomainsRepository: supportedDomainsRepository
    ) { [weak self] action in
      guard let self = self else { return }
      switch action {
      case let .setupAuthentication(credential):
        self.setupAuthentication(for: credential)
      case .addNewLogin:
        self.deepLinkingService.handleLink(.vault(.create(.credential)))
      }
    }
  }

  func makeTokenListViewModel() -> OTPTokenListViewModel {
    return otpTokenListViewModelFactory.make { [weak self] action in
      guard let self = self else { return }
      switch action {
      case .setupAuthentication:
        self.setupAuthentication(for: nil)
      case .displayExplorer:
        self.add(.explorer(isFirstView: false))
      }
    }
  }

  func makeAddOTPFlowViewModel() -> AddOTPFlowViewModel {
    selectedCredential = nil

    let mode: AddOTPFlowViewModel.Mode =
      selectedCredential.map(AddOTPFlowViewModel.Mode.credentialPrefilled) ?? .newCredential
    return addOTPFlowViewModelFactory.make(otpURL: otpURL, mode: mode) { [weak self] in
      self?.otpURL = nil
      self?.steps = [.otpList]
    }
  }

  func setupAuthentication(for credential: Credential? = nil) {
    selectedCredential = credential
    presentAdd2FAFlow = true
  }

  func add(_ navigationStep: Step) {
    steps.append(navigationStep)
  }

  func replaceFirstStep(by replacementStep: Step) {
    if steps.isEmpty {
      add(replacementStep)
    } else {
      steps[0] = replacementStep
    }
  }
}

extension AuthenticatorToolFlowViewModel {
  static var mock: AuthenticatorToolFlowViewModel {
    .init(
      activityReporter: .mock,
      deepLinkingService: DeepLinkingService.fakeService,
      otpDatabaseService: OTPDatabaseService.mock,
      iconService: IconServiceMock(),
      otpExplorerViewModelFactory: .init({ _, _ in .mock }),
      otpTokenListViewModelFactory: .init({ _ in .mock }),
      credentialDetailViewModelFactory: .init({ _, _, _, _, _, _ in
        MockVaultConnectedContainer().makeCredentialDetailViewModel(
          item: PersonalDataMock.Credentials.amazon, mode: .viewing)
      }),
      addOTPFlowViewModelFactory: .init({ _, _, _ in .mock })
    )
  }
}
