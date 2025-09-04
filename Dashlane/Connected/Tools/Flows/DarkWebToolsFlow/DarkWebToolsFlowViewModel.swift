import Combine
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import VaultKit

@MainActor
class DarkWebToolsFlowViewModel: ObservableObject, SessionServicesInjecting {

  enum Step {
    case root
    case detail(DWMSimplifiedBreach)
    case credentialDetails(Credential)
  }

  enum Sheet: String, Identifiable {
    var id: String { rawValue }
    case addEmail
  }

  @Published
  var steps: [Step] = [.root]

  @Published
  var presentedSheet: Sheet?

  let actionPublisher = PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>()
  private var cancellables = Set<AnyCancellable>()

  enum Action {
    case addEmail
    case deleteEmail(String)
    case upgradeToPremium
    case showDetails(DWMSimplifiedBreach)
    case deleteAndPop(DWMSimplifiedBreach)
    case changePassword(Credential, (Result<Void, Error>) -> Void)
    case showCredential(Credential)
  }

  @Loggable
  enum DWMCoordinatorError: Error {
    case paywall
  }

  let session: Session
  let userSettings: UserSettings
  let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
  let deepLinkingService: DeepLinkingServiceProtocol
  let darkWebMonitoringViewModelFactory: DarkWebMonitoringViewModel.Factory
  let dataLeakMonitoringAddEmailViewModelFactory: DataLeakMonitoringAddEmailViewModel.Factory
  let darkWebMonitoringDetailsViewModelFactory: DarkWebMonitoringDetailsViewModel.Factory
  let breachViewModelFactory: BreachViewModel.SecondFactory
  let userDeviceAPIClient: UserDeviceAPIClient
  let notificationService: SessionNotificationService
  let identityDashboardService: IdentityDashboardServiceProtocol
  let logger: Logger
  let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory

  init(
    session: Session,
    userSettings: UserSettings,
    darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
    deepLinkingService: DeepLinkingServiceProtocol,
    darkWebMonitoringViewModelFactory: DarkWebMonitoringViewModel.Factory,
    dataLeakMonitoringAddEmailViewModelFactory: DataLeakMonitoringAddEmailViewModel.Factory,
    darkWebMonitoringDetailsViewModelFactory: DarkWebMonitoringDetailsViewModel.Factory,
    breachViewModelFactory: BreachViewModel.SecondFactory,
    userDeviceAPIClient: UserDeviceAPIClient,
    notificationService: SessionNotificationService,
    identityDashboardService: IdentityDashboardServiceProtocol,
    logger: Logger,
    credentialDetailViewModelFactory: CredentialDetailViewModel.Factory
  ) {
    self.session = session
    self.userSettings = userSettings
    self.darkWebMonitoringService = darkWebMonitoringService
    self.deepLinkingService = deepLinkingService
    self.darkWebMonitoringViewModelFactory = darkWebMonitoringViewModelFactory
    self.dataLeakMonitoringAddEmailViewModelFactory = dataLeakMonitoringAddEmailViewModelFactory
    self.darkWebMonitoringDetailsViewModelFactory = darkWebMonitoringDetailsViewModelFactory
    self.breachViewModelFactory = breachViewModelFactory
    self.userDeviceAPIClient = userDeviceAPIClient
    self.notificationService = notificationService
    self.identityDashboardService = identityDashboardService
    self.logger = logger
    self.credentialDetailViewModelFactory = credentialDetailViewModelFactory

    actionPublisher.receive(on: RunLoop.main).sink { [weak self] action in
      guard let self = self else { return }
      switch action {
      case .addEmail:
        self.showAddEmailFlow()
      case .deleteEmail(let email):
        self.delete(email: email)
      case .upgradeToPremium:
        self.upgradeToPremium()
      case .showDetails(let breach):
        self.showDetailView(breach)
      case .deleteAndPop(let breach):
        self.deleteAndPop(breach)
      case .changePassword(let breach, let completion):
        self.changePassword(for: breach, completion: completion)
      case .showCredential(let credential):
        self.showCredential(credential)
      }
    }
    .store(in: &cancellables)
  }

  func appeared() {
    darkWebMonitoringService.refresh()
  }
}

extension DarkWebToolsFlowViewModel {

  func makeDarkWebMonitoringDetailsViewModel(for breach: DWMSimplifiedBreach)
    -> DarkWebMonitoringDetailsViewModel
  {
    return darkWebMonitoringDetailsViewModelFactory.make(
      breach: breach,
      breachViewModel: breachViewModelFactory.make(breach: breach),
      actionPublisher: actionPublisher)
  }

  func makeDataLeakMonitoringAddEmailViewModel() -> DataLeakMonitoringAddEmailViewModel {
    return dataLeakMonitoringAddEmailViewModelFactory.make(login: session.login)
  }

  func showAddEmailFlow() {
    self.presentedSheet = .addEmail
  }

  func delete(email: String) {
    darkWebMonitoringService.removeFromMonitoredEmails(email: email)
  }

  func upgradeToPremium() {
    deepLinkingService.handleLink(.premium(.getPremium))
  }

  func showDetailView(_ breach: DWMSimplifiedBreach) {
    if breach.status != .solved {
      darkWebMonitoringService.viewed(breach)
    }
    self.steps.append(.detail(breach))
  }

  func deleteAndPop(_ simplifiedBreach: DWMSimplifiedBreach) {
    darkWebMonitoringService.delete(simplifiedBreach)
    self.steps.removeLast()
  }

  func changePassword(
    for credential: Credential,
    completion: (Result<Void, Error>) -> Void
  ) {
    completion(.success)
    self.steps.append(.credentialDetails(credential))
  }

  func showCredential(_ credential: Credential) {
    deepLinkingService.handleLink(
      .vault(.show(credential, useEditMode: false, origin: .darkWebMonitoring)))
  }
}

extension DarkWebToolsFlowViewModel {
  static var mock: DarkWebToolsFlowViewModel {
    .init(
      session: .mock,
      userSettings: .mock,
      darkWebMonitoringService: DarkWebMonitoringServiceMock(),
      deepLinkingService: DeepLinkingService.fakeService,
      darkWebMonitoringViewModelFactory: .init({ _ in .mock }),
      dataLeakMonitoringAddEmailViewModelFactory: .init({ _ in .mock }),
      darkWebMonitoringDetailsViewModelFactory: .init({ _, _, _ in .fake() }),
      breachViewModelFactory: .init({ _ in .mock(for: .init()) }),
      userDeviceAPIClient: .mock({}),
      notificationService: .fakeService,
      identityDashboardService: IdentityDashboardService.mock,
      logger: .mock,
      credentialDetailViewModelFactory: .init({ _, _, _, _, _, _ in
        MockVaultConnectedContainer().makeCredentialDetailViewModel(
          item: PersonalDataMock.Credentials.amazon, mode: .viewing)
      }))
  }
}

extension DarkWebToolsFlowViewModel {
  func makeCredentialDetailViewModel(credential: Credential) -> CredentialDetailViewModel {
    return credentialDetailViewModelFactory.make(item: credential, mode: .updating)
  }
}
