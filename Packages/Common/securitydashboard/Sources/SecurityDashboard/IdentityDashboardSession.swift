import Foundation
import DashTypes
import Combine

public protocol IdentityDashboardSessionDelegate: AnyObject {
        func credentialsDataDidUpdate()

        func passwordHealthDataDidUpdate()
}

public class IdentityDashboardSession {

    private var credentialsProvider: CredentialsProvider
    private var breachesStore: BreachesStore

    private let passwordsSimilarityOperation = PasswordsSimilarityOperation()

    private let log: Logger

    private let computationQueue = DispatchQueue(label: "IdentityDashboardSessionMainQueue", qos: .background)

    private var breachesUpdatedOnce: Bool = false
    private var credentialsUpdatedOnce: Bool = false

        private let webservice: LegacyWebService
    private let alertsInformationProvider: BreachesManagerAlertsInfoProvider
    private let localizationProvider: LocalizationProvider
    private let breachesService: BreachesService
    private let credentialsService: CredentialsService
    private var passwordHealthDataProducer: PasswordHealthAnalyzer 
    private var cancellables = Set<AnyCancellable>()

    public weak var delegate: IdentityDashboardSessionDelegate?

    @Published
    public var breaches: [StoredBreach] = []

    @Published
    public var popupAlerts: [PopupAlertProtocol] = []

    public var credentialsPublisher: AnyPublisher<[SecurityDashboardCredential], Never> {
        credentialsService.$cachedCredentials.eraseToAnyPublisher()
    }

    private var subscriptions = Set<AnyCancellable>()

        public init(
        credentialsProvider: CredentialsProvider,
        breachesStore: BreachesStore,
        webservice: LegacyWebService,
        alertsInformationProvider: BreachesManagerAlertsInfoProvider,
        localizationProvider: LocalizationProvider,
        notificationManager: IdentityDashboardNotificationManager,
        logger: Logger
    ) {
        self.credentialsProvider = credentialsProvider
        self.breachesStore = breachesStore
        self.webservice = webservice
        self.alertsInformationProvider = alertsInformationProvider
        self.localizationProvider = localizationProvider
        self.log = logger

        let credentialsService = CredentialsService(credentialsProvider: credentialsProvider,
                                                     passwordsSimilarityOperation: passwordsSimilarityOperation,
                                                     queue: self.computationQueue,
                                                     log: log)

        self.breachesService = BreachesService(breachesStore: breachesStore,
                                               cachedBreachCredentialsPublisher: credentialsService.cachedBreachCredentialsPublisher,
                                               webservice: webservice,
                                               alertsInformationProvider: self.alertsInformationProvider,
                                               localization: localizationProvider,
                                               logger: log)

        self.credentialsService = credentialsService
        self.passwordHealthDataProducer = PasswordHealthAnalyzer(
            passwordsSimilarityOperation: passwordsSimilarityOperation,
            notificationManager: notificationManager
        )

        credentialsService.delegate = self

        breachesStore.breachesPublisher()
            .receive(on: DispatchQueue.main)
            .map { Array($0) }
            .assign(to: &$breaches)

        breachesService.popupAlertPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$popupAlerts)

        breachesService.cachedBreaches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.breachesUpdatedOnce = true
                                if self.credentialsUpdatedOnce {
                    self.credentialsService.refreshCompromisedInCache()
                }
                self.refreshPasswordHealth()
            }
            .store(in: &subscriptions)
    }

    public func finish(completion: @escaping () -> Void) {
        computationQueue.async { [weak self] in
            self?.breachesService.cancel()
            completion()
        }
    }

    public func dataLeaksUpdatePublisher() -> AnyPublisher<Void, Error> {
        Future<AnyPublisher<Void, Error>, Never> { promise in
            Task {
                let publisher = await self.breachesService.dataLeaksUpdateFinished.eraseToAnyPublisher()
                promise(.success(publisher))
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

        private func refreshPasswordHealth() {
                guard breachesUpdatedOnce && credentialsUpdatedOnce else {
            return
        }

        Task {
            await passwordHealthDataProducer.reset(with: credentialsService.cachedCredentials)
            delegate?.passwordHealthDataDidUpdate()
        }
    }
}

extension IdentityDashboardSession {
    public func credentials(forBreachId breach: String) -> [SecurityDashboardCredential] {
        return credentialsService.cachedBreachCredentials[breach] ?? []
    }
}

extension IdentityDashboardSession: CredentialsServiceDelegate {
    func credentialsServiceDidUpdate() {
        self.delegate?.credentialsDataDidUpdate()
        credentialsUpdatedOnce = true
        refreshPasswordHealth()
    }

    func breachesByPasswords() async -> BreachesByPasswords {
        return await breachesService.breachesByPasswords
    }
}

public extension IdentityDashboardSession {
    @MainActor
    func fetchPublicBreachesAndDataLeaks(for credentials: [SecurityDashboardCredential],
                                         using decryptor: DataLeakInformationDataDecryptor?) async throws {
        try await self.breachesService.fetchBreaches(for: credentials, using: decryptor)
    }

    @MainActor
    func fetchPublicBreaches(for credentials: [SecurityDashboardCredential]) async {
        await self.breachesService.fetchPublicBreaches(for: credentials)
    }

    func fetchDataLeaks(for credentials: [SecurityDashboardCredential],
                        using decryptor: DataLeakInformationDataDecryptor?) async throws {
        try await self.breachesService.fetchDataLeaks(for: credentials,
                                                         using: decryptor)
    }

    func mark(breaches: [BreachesService.Identifier], as status: StoredBreach.Status) async {
        await breachesService.mark(breachIDs: breaches, as: status)
    }

    func trayAlerts() async -> [TrayAlertProtocol] {
        await breachesService.trayAlerts(for: credentialsService.cachedBreachCredentials)
    }

    func trayAlertsPublisher() -> AnyPublisher<[TrayAlertProtocol], Never> {
        breachesService.trayAlertsPublisher(breachPublisher: $breaches.eraseToAnyPublisher())
    }
}

public extension IdentityDashboardSession {

    func report(spaceId: String?, onCompletion: @escaping (PasswordHealthReport) -> Void) {
        Task {
            let report = await self.passwordHealthDataProducer.report(for: .init(spaceId: spaceId))
            await MainActor.run {
                onCompletion(report)
            }
        }
    }

    func report(spaceId: String?) -> AnyPublisher<PasswordHealthReport, Never> {
        return passwordHealthDataProducer.report(for: .init(spaceId: spaceId))
    }

    func data(for requests: [PasswordHealthAnalyzer.Request], onCompletion: @escaping ([PasswordHealthAnalyzer.Request: PasswordHealthResult]) -> Void) {
        Task {
            let data = await self.passwordHealthDataProducer.compute(for: requests)
            await MainActor.run {
                onCompletion(data)
            }
        }
    }

    func data(for request: PasswordHealthAnalyzer.Request) async -> PasswordHealthResult {
        return await passwordHealthDataProducer.compute(for: request)
    }

    func data(for request: PasswordHealthAnalyzer.Request) -> AnyPublisher<PasswordHealthResult, Never> {
        return passwordHealthDataProducer.compute(for: request)
    }

    func data(for requests: [PasswordHealthAnalyzer.Request]) async -> [PasswordHealthAnalyzer.Request: PasswordHealthResult] {
        return await passwordHealthDataProducer.compute(for: requests)
    }

    func data(for requests: [PasswordHealthAnalyzer.Request]) -> AnyPublisher<[PasswordHealthAnalyzer.Request: PasswordHealthResult], Never> {
        return passwordHealthDataProducer.compute(for: requests)
    }

    func numberOfTimesPasswordIsReused(password: String, onCompletion: @escaping (Int) -> Void) {
        Task {
            let count = await self.passwordHealthDataProducer.reusedCount(for: password)
            await MainActor.run {
                onCompletion(count)
            }
        }
    }

    func isCredentialCompromised(credentialID: String, onCompletion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.credentialsService.isCredentialCompromised(credentialID: credentialID, onCompletion: onCompletion)
        }
    }
}

public extension IdentityDashboardSession {
    func compromisedCredentials() -> Future<[String], Never> {
        return self.credentialsService.compromisedCredentials()
    }

    func reusedCredentials() -> Future<[String], Never> {
        Future<[String], Never> {  [passwordHealthDataProducer] promise in
            Task {
                let reusedCredentials = await passwordHealthDataProducer.reusedPasswords()
                promise(.success(reusedCredentials))
            }
        }
    }
}
