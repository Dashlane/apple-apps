import Foundation
import CorePersonalData
import Combine
import CoreSettings
import CoreSession
import DashTypes
import CoreNetworking
import VaultKit

@MainActor
class DarkWebToolsFlowViewModel: ObservableObject, SessionServicesInjecting {

    enum Step {
        case root
        case detail(DWMSimplifiedBreach)
                case credentialDetails(CredentialDetailViewModel)
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
        case changePassword(Credential, Bool, (Result<Void, Error>) -> Void)
        case showCredential(Credential)
    }

    enum DWMCoordinatorError: Error {
        case paywall
        case fallbackMinibrowser
    }

    let session: Session
    let userSettings: UserSettings
    let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
    let deepLinkingService: DeepLinkingServiceProtocol
    let darkWebMonitoringViewModelFactory: DarkWebMonitoringViewModel.Factory
    let dataLeakMonitoringAddEmailViewModelFactory: DataLeakMonitoringAddEmailViewModel.Factory
    let darkWebMonitoringDetailsViewModelFactory: DarkWebMonitoringDetailsViewModel.Factory
    let breachViewModelFactory: BreachViewModel.SecondFactory
    let webservice: LegacyWebService
    let notificationService: SessionNotificationService
    let logger: Logger
    let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory

    init(session: Session,
         userSettings: UserSettings,
         darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
         deepLinkingService: DeepLinkingServiceProtocol,
         darkWebMonitoringViewModelFactory: DarkWebMonitoringViewModel.Factory,
         dataLeakMonitoringAddEmailViewModelFactory: DataLeakMonitoringAddEmailViewModel.Factory,
         darkWebMonitoringDetailsViewModelFactory: DarkWebMonitoringDetailsViewModel.Factory,
         breachViewModelFactory: BreachViewModel.SecondFactory,
         webservice: LegacyWebService,
         notificationService: SessionNotificationService,
         logger: Logger,
         credentialDetailViewModelFactory: CredentialDetailViewModel.Factory) {
        self.session = session
        self.userSettings = userSettings
        self.darkWebMonitoringService = darkWebMonitoringService
        self.deepLinkingService = deepLinkingService
        self.darkWebMonitoringViewModelFactory = darkWebMonitoringViewModelFactory
        self.dataLeakMonitoringAddEmailViewModelFactory = dataLeakMonitoringAddEmailViewModelFactory
        self.darkWebMonitoringDetailsViewModelFactory = darkWebMonitoringDetailsViewModelFactory
        self.breachViewModelFactory = breachViewModelFactory
        self.webservice = webservice
        self.notificationService = notificationService
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
            case .changePassword(let breach, let isMiniBrowserAvailable, let completion):
                self.changePassword(for: breach, isMiniBrowserAvailable: isMiniBrowserAvailable, completion: completion)
            case .showCredential(let credential):
                self.showCredential(credential)
            }
        }
        .store(in: &cancellables)
    }

    func appeared() {
        darkWebMonitoringService.refresh()
        userSettings[.hasSeenDWMExperience] = true
    }
}

extension DarkWebToolsFlowViewModel {

    func makeDarkWebMonitoringDetailsViewModel(for breach: DWMSimplifiedBreach) -> DarkWebMonitoringDetailsViewModel {
        return darkWebMonitoringDetailsViewModelFactory.make(breach: breach,
                                                             breachViewModel: breachViewModelFactory.make(breach: breach),
                                                             actionPublisher: actionPublisher)
    }

    func makeDataLeakMonitoringAddEmailViewModel() -> DataLeakMonitoringAddEmailViewModel {
        return dataLeakMonitoringAddEmailViewModelFactory.make(login: session.login,
                                                               dataLeakService: DataLeakMonitoringRegisterService(webservice: webservice, notificationService: notificationService, logger: logger))
    }

    func showAddEmailFlow() {
        self.presentedSheet = .addEmail
    }

    func delete(email: String) {
        darkWebMonitoringService.identityDashboardService.dataLeakMonitoringRegisterService.removeFromMonitoredEmails(emails: [email])
    }

    func upgradeToPremium() {
        deepLinkingService.handleLink(.other(.getPremium, origin: "dark_web"))
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

    func changePassword(for credential: Credential,
                        isMiniBrowserAvailable: Bool,
                        completion: (Result<Void, Error>) -> Void) {
        if !isMiniBrowserAvailable {
            let viewModel = credentialDetailViewModelFactory.make(item: credential, mode: .updating)
            completion(.success)
            self.steps.append(.credentialDetails(viewModel))
        } else {
            completion(.failure(DWMCoordinatorError.fallbackMinibrowser))
        }
    }

    func showCredential(_ credential: Credential) {
        deepLinkingService.handleLink(.vault(.show(credential, useEditMode: false, origin: .darkWebMonitoring)))
    }
}

extension DarkWebToolsFlowViewModel {
    static var mock: DarkWebToolsFlowViewModel {
        .init(session: .mock,
              userSettings: .mock,
              darkWebMonitoringService: DarkWebMonitoringServiceMock(),
              deepLinkingService: DeepLinkingService.fakeService,
              darkWebMonitoringViewModelFactory: .init({ _ in .mock }),
              dataLeakMonitoringAddEmailViewModelFactory: .init({ _, _ in .mock }),
              darkWebMonitoringDetailsViewModelFactory: .init({ _, _, _ in .fake() }),
              breachViewModelFactory: .init({ _ in .mock(for: .init()) }),
              webservice: LegacyWebServiceMock(response: ""),
              notificationService: .fakeService,
              logger: LoggerMock(),
              credentialDetailViewModelFactory: .init({ _, _, _, _, _, _ in MockVaultConnectedContainer().makeCredentialDetailViewModel(item: PersonalDataMock.Credentials.amazon, mode: .viewing) }))
    }
}
