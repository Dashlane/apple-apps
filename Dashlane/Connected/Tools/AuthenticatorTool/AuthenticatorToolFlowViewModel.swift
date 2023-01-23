import Foundation
import CoreUserTracking
import Combine
import CorePersonalData
import AuthenticatorKit
import IconLibrary
import DashlaneAppKit
import VaultKit
import DashTypes
import CoreSettings

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

    @Published
    var isIntroSheetPresented: Bool = false

    private let iconService: IconServiceProtocol
    private let deepLinkingService: DeepLinkingServiceProtocol
    private let otpDatabaseService: OTPDatabaseService
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol
    private let otpExplorerViewModelFactory: OTPExplorerViewModel.Factory
    private let otpTokenListViewModelFactory: OTPTokenListViewModel.Factory
    private let supportedDomainsRepository: OTPSupportedDomainsRepository
    private let addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory
    private var cancellables = Set<AnyCancellable>()
    private let settings: KeyedSettings<AuthenticatorToolIntroSettingsKey>

    let credentialDetailViewModelProvider: CredentialDetailViewModel.Factory

    init(vaultItemsService: VaultItemsServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         deepLinkingService: DeepLinkingServiceProtocol,
         iconService: IconServiceProtocol,
         settings: LocalSettingsStore,
         otpExplorerViewModelFactory: OTPExplorerViewModel.Factory,
         otpTokenListViewModelFactory: OTPTokenListViewModel.Factory,
         credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
         addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory
    ) {
        self.activityReporter = activityReporter
        self.otpDatabaseService = OTPDatabaseService(vaultItemsService: vaultItemsService, activityReporter: activityReporter)
        self.vaultItemsService = vaultItemsService
        self.supportedDomainsRepository = OTPSupportedDomainsRepository()
        self.deepLinkingService = deepLinkingService
        self.otpExplorerViewModelFactory = otpExplorerViewModelFactory
        self.otpTokenListViewModelFactory = otpTokenListViewModelFactory
        self.credentialDetailViewModelProvider = credentialDetailViewModelFactory
        self.addOTPFlowViewModelFactory = addOTPFlowViewModelFactory
        self.iconService = iconService
        self.settings = settings.keyed(by: AuthenticatorToolIntroSettingsKey.self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isIntroSheetPresented = !(self.settings[.hasSeenAuthenticatorToolIntro] ?? false)
        }
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

    }

    func makeExplorerViewModel() -> OTPExplorerViewModel {
        return otpExplorerViewModelFactory.make(otpSupportedDomainsRepository: supportedDomainsRepository) { [weak self] action in
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
        return otpTokenListViewModelFactory.make(authenticatorDatabaseService: otpDatabaseService, domainIconLibray: iconService.domain) { [weak self] action in
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

        let mode: AddOTPFlowViewModel.Mode = selectedCredential.map(AddOTPFlowViewModel.Mode.credentialPrefilled) ?? .newCredential(credentialDetailViewModelProvider)
        return addOTPFlowViewModelFactory.make(mode: mode) { [weak self] in
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

    func introCompleted() {
        self.settings[.hasSeenAuthenticatorToolIntro] = true
        self.isIntroSheetPresented = false
    }

    func replaceFirstStep(by replacementStep: Step) {
        if steps.isEmpty {
            add(replacementStep)
        } else {
            steps[0] = replacementStep
        }
    }
}

private enum AuthenticatorToolIntroSettingsKey: String, LocalSettingsKey {
    case hasSeenAuthenticatorToolIntro

    var type: Any.Type {
        return Bool.self
    }
}

extension AuthenticatorToolFlowViewModel {
    static var mock: AuthenticatorToolFlowViewModel {
        let container = MockServicesContainer()
        return AuthenticatorToolFlowViewModel(vaultItemsService: container.vaultItemsService,
                                              activityReporter: .fake,
                                              deepLinkingService: DeepLinkingService.fakeService,
                                              iconService: IconServiceMock(),
                                              settings: InMemoryLocalSettingsStore(),
                                              otpExplorerViewModelFactory: .init({ _, _ in .mock }),
                                              otpTokenListViewModelFactory: .init({ _, _, _ in .mock }),
                                              credentialDetailViewModelFactory: .init({ _, _, _, _, _, _ in MockVaultConnectedContainer().makeCredentialDetailViewModel(item: PersonalDataMock.Credentials.amazon, mode: .viewing) }),
                                              addOTPFlowViewModelFactory: .init({ _, _ in .mock }))
    }
}
