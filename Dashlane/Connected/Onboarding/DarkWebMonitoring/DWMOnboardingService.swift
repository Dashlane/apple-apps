import Foundation
import UIKit
import SecurityDashboard
import Combine
import DashTypes
import DomainParser
import CorePersonalData
import CoreFeature
import DashlaneAppKit
import CoreSettings

class DWMOnboardingService {

        var canShowDWMOnboarding: Bool {
                guard darkWebMonitoringService.isDwmEnabled == true else { return false }

                guard UIDevice.current.userInterfaceIdiom != .pad else { return false }

                guard settings[.hasSeenUnexpectedError] != true else { return false }

        return true
    }

        var shouldShowLastChanceScanPrompt: Bool {
        guard canShowDWMOnboarding else { return false }
        guard settings[.progress] == DWMOnboardingProgress.shown else { return false }
        guard settings[.hasDismissedLastChanceScanPrompt] != true else { return false }

        return true
    }

        var shouldShowBreachesNotFoundInImportMethodsView: Bool {
        guard settings[.hasConfirmedEmailFromOnboardingChecklist] == true, settings[.progress] == DWMOnboardingProgress.breachesNotFound, settings[.hasSeenUnexpectedError] != true else { return false }
        return true
    }

        @Published var pendingBreaches = [DWMSimplifiedBreach]()

        @Published private var securedItemsIds = [String]()

    private let settings: DWMOnboardingSettings
    private let identityDashboardService: IdentityDashboardServiceProtocol
    private let personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder
    private let vaultItemsService: VaultItemsServiceProtocol
    private let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
    private let logger: Logger
    private var cancellables = Set<AnyCancellable>()

    init(settings: DWMOnboardingSettings,
         identityDashboardService: IdentityDashboardServiceProtocol,
         personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder,
         vaultItemsService: VaultItemsServiceProtocol,
         darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
         logger: Logger) {
        self.identityDashboardService = identityDashboardService
        self.settings = settings
        self.personalDataURLDecoder = personalDataURLDecoder
        self.vaultItemsService = vaultItemsService
        self.darkWebMonitoringService = darkWebMonitoringService
        self.logger = logger

        setupSecurityBreachesSubscription()
        setupSecuredItemsIdsSubscription()
        setupBreachesUpdateSubscription()
    }

        typealias Email = String

        func register(email: Email) -> AnyPublisher<Void, DWMEmailRegistrationError> {

        return darkWebMonitoringService
            .register(email: email)
            .mapError { [weak self] error -> DWMEmailRegistrationError in
                if case let .unexpectedError(error) = error {
                    self?.logger.fatal("Email registration error", error: error)
                }
                return error
            }
            .map { [settings] email -> AnyPublisher<Void, DWMEmailRegistrationError> in
                settings.updateProgress(.emailRegistrationRequestSent)
                settings[.registeredEmail] = email
                return Just(()).setFailureType(to: DWMEmailRegistrationError.self).eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    enum EmailStateCheckError: Error {
        case connectionError
        case unexpectedError(details: String)
    }

    func emailStatePublisher(email: String) -> AnyPublisher<DataLeakEmail.State, EmailStateCheckError> {
        let didBecomeActivePublisher = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        let statePublisher = didBecomeActivePublisher
            .setFailureType(to: EmailStateCheckError.self)
            .map { _ in self.getState(email: email) }
            .switchToLatest()

        return statePublisher.eraseToAnyPublisher()
    }

    func getState(_ notification: Notification? = nil, email: String) -> AnyPublisher<DataLeakEmail.State, EmailStateCheckError> {
        return Future.init { [weak self] promise in
            guard let self = self else {
                return
            }
            self.darkWebMonitoringService.updateMonitoredEmails { [weak self] result in
                guard let self = self else { return }
                promise(self.handleResult(result))
            }
        }.eraseToAnyPublisher()
    }

    func state(forEmail: String, completion: @escaping (Result<DataLeakEmail.State, EmailStateCheckError>) -> Void) {
        darkWebMonitoringService.updateMonitoredEmails { [weak self] result in
            guard let self = self else { return }
            completion(self.handleResult(result))
        }
    }

    func handleResult(_ result: Result<DataLeakMonitoringStatusResponse, Error>) -> Result<DataLeakEmail.State, EmailStateCheckError> {
        switch result {
        case .success(let response):
            if let email = response.emails.first {
                if email.state == .disabled {
                    self.logger.fatal("Email for registration is unexpectedly disabled.")
                }
                return .success(email.state)
            } else {
                self.logger.fatal("Email registration status check: empty response, one email is expected.")
                return .failure(.unexpectedError(details: "Email registration status check: empty response, one email is expected."))
            }
        case .failure(let error):
            if error.isConnectionError {
                return .failure(.connectionError)
            } else {
                self.logger.fatal("Email status check error", error: error)
                return .failure(.unexpectedError(details: String(reflecting: error)))
            }
        }
    }

        enum BreachesFetchingError: Error {
        case unknownError
    }

    func fetchBreachedAccounts() -> AnyPublisher<[DWMSimplifiedBreach], Error> {
        if identityDashboardService.hasLastDataLeaksUpdateFinishedWithError {
            identityDashboardService.refreshDataLeaks()
        }

        return breachesUpdatePublisher()
            .map { update, breaches -> AnyPublisher<[DWMSimplifiedBreach], Error> in

                                if !breaches.isEmpty {
                    return Just(breaches).setFailureType(to: Error.self).eraseToAnyPublisher()
                }

                                if let error = update.error {
                    return Fail(error: error).eraseToAnyPublisher()
                }

                                return Just(breaches).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

        func remove(_ breach: DWMSimplifiedBreach) {
        darkWebMonitoringService.delete(breach)

        if pendingBreaches.isEmpty {
            settings[.hasAddressedAllBreaches] = true
        }
    }

    func itemSavedToVault(_ item: Credential, for breach: DWMSimplifiedBreach) {
        var securedItemsIds = settings[.securedItemsIds] ?? [String]()
        securedItemsIds.append(item.id.rawValue)
        settings[.securedItemsIds] = securedItemsIds
        remove(breach)

        if pendingBreaches.isEmpty {
            settings[.hasAddressedAllBreaches] = true
        }
    }

        func securedItemsPublisher() -> AnyPublisher<[Credential], Never> {
        return vaultItemsService
            .$credentials.removeDuplicates()
            .combineLatest($securedItemsIds.removeDuplicates())
            .map { (credentials, securedItemsIds) -> [Credential] in
                credentials.filter { securedItemsIds.contains($0.id.rawValue) }
        }.eraseToAnyPublisher()
    }

        private func breachesUpdatePublisher() -> AnyPublisher<(IdentityDashboardService.DataLeaksUpdate, [DWMSimplifiedBreach]), Never> {
        let registeredEmailPublisher: AnyPublisher<String, Never> = settings.publisher(for: .registeredEmail)
            .compactMap { $0 }
            .eraseToAnyPublisher()

        let dataLeakUpdateForRegisteredEmailPublisher = identityDashboardService.dataLeaksLastUpdatePublisher.combineLatest(registeredEmailPublisher)
            .filter { update, registeredEmail in
                update.emails.contains { $0.email == registeredEmail }
            }
            .map { $0.0 }
            .eraseToAnyPublisher()

                let debouncedBreachesPublisher = $pendingBreaches.debounce(for: 2, scheduler: DispatchQueue.main)

        return dataLeakUpdateForRegisteredEmailPublisher
            .map { updatePublisher in
                return Just(updatePublisher).combineLatest(debouncedBreachesPublisher)
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

                    private func setupSecuredItemsIdsSubscription() {
        let securedItemsIdsPublisher: AnyPublisher<[String]?, Never> = settings.changeMonitoringPublisher(key: .securedItemsIds)
        securedItemsIdsPublisher
            .prepend(settings[.securedItemsIds])
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &$securedItemsIds)
    }

    private func setupSecurityBreachesSubscription() {
        darkWebMonitoringService.breachesPublisher
            .assign(to: &$pendingBreaches)
    }

        private func setupBreachesUpdateSubscription() {
        if let settings = settings[.progress] as DWMOnboardingProgress?, settings >= .emailConfirmed {
            return
        }

        breachesUpdatePublisher()
            .first()
            .sink { [weak self] _, breaches in
                if breaches.isEmpty {
                    self?.settings.updateProgress(.breachesNotFound)
                } else {
                    self?.settings.updateProgress(.breachesFound)
                }
            }
            .store(in: &cancellables)
    }

        func breachesViewed() {
        if settings[.breachesMarkedAsViewed] != true {
            let breachesIds = pendingBreaches.map { $0.breachId }
            Task {
                await identityDashboardService.session.mark(breaches: breachesIds, as: .viewed)
                self.settings[.breachesMarkedAsViewed] = true
            }
        }
    }

            func shown() {
        settings.updateProgress(.shown)
    }

        func skip() {
        if (settings[.progress] as DWMOnboardingProgress?) == .shown {
            settings[.hasSkippedDarkWebMonitoringOnboarding] = true 
        }
    }

        func hideDWMOnboarding() {
        settings[.hasSeenUnexpectedError] = true
    }

        func dwmOnboardingNotShownInAccountCreation() {
        settings[.darkWebMonitoringOnboardingCouldNotBeShown] = true
    }

        func progressPublisher() -> AnyPublisher<DWMOnboardingProgress?, Never> {
        return settings.changeMonitoringPublisher(key: .progress).prepend(settings[.progress]).eraseToAnyPublisher()
    }
}

private extension IdentityDashboardServiceProtocol {
    var hasLastDataLeaksUpdateFinishedWithError: Bool {
        return dataLeaksLastUpdate.error != nil
    }

    func refreshDataLeaks() {
        dataLeaksUpdateRequested.send()
    }
}

 extension DWMOnboardingService {
    static var mock: DWMOnboardingService {
        .init(
            settings: .init(internalStore: InMemoryLocalSettingsStore()),
            identityDashboardService: IdentityDashboardService.mock,
            personalDataURLDecoder: .init(domainParser: DomainParserMock(), linkedDomainService: LinkedDomainService()),
            vaultItemsService: MockServicesContainer().vaultItemsService,
            darkWebMonitoringService: DarkWebMonitoringServiceMock(),
            logger: LoggerMock()
        )
    }
 }
