import Foundation
import DashTypes
import Combine

public struct DeltaUpdateBreaches {
    public let inserted: Set<StoredBreach>
    public let updated: Set<StoredBreach>
    
    public var isEmpty: Bool {
        return inserted.isEmpty && updated.isEmpty
    }
}

public protocol BreachesManagerAlertsInfoProvider: AnyObject {
    var requestInformation: AlertGenerator.RequestInformation { get }
}

public protocol DataLeakInformationDataDecryptor {
            func decrypt(data: Data, using encryptedCipherKey: Data) -> Data?
}

typealias BreachesByPasswords = [BreachesService.Password: Set<Breach>]

public actor BreachesService: Cancelable {

        public typealias Password = String
    public typealias Identifier = String

        public var dataLeaksUpdateFinished = PassthroughSubject<Void, Error>()
    private var breachesStore: BreachesStore
    private let webservice: LegacyWebService
    private let alertsInformationProvider: BreachesManagerAlertsInfoProvider
    private let localization: LocalizationProvider
    private let fetcher: BreachesFetcher
    private let log: Logger
    internal nonisolated let cachedBreaches = CurrentValueSubject<Set<StoredBreach>, Never>([])
    private let cachedBreachCredentialsPublisher: AnyPublisher<CredentialsService.CredentialsByBreachId, Never>
    
        @Published
    var breachesByPasswords: BreachesByPasswords = [:]
    
    private var subscriptions = Set<AnyCancellable>()

    
        init(breachesStore: BreachesStore,
         cachedBreachCredentialsPublisher: AnyPublisher<CredentialsService.CredentialsByBreachId, Never>,
         webservice: LegacyWebService,
         alertsInformationProvider: BreachesManagerAlertsInfoProvider,
         localization: LocalizationProvider,
         logger: Logger) {
        self.cachedBreachCredentialsPublisher = cachedBreachCredentialsPublisher
        self.breachesStore = breachesStore
        self.webservice = webservice
        self.log = logger
        self.localization = localization
        self.alertsInformationProvider = alertsInformationProvider
        self.fetcher = BreachesFetcher(webservice: webservice, logger: logger)
        self.setupPublisher()
    }
    
    private func setupPublisher() {
        breachesStore
            .breachesPublisher()
            .sink(receiveValue: { value in
                self.cachedBreaches.send(value)
            })
            .store(in: &subscriptions)
        
        cachedBreaches
            .map { $0.breachesByPasswords() }
            .assign(to: &$breachesByPasswords)
    }
    
    nonisolated func cancel() {
            }
    
        func fetchBreaches(for credentials: [SecurityDashboardCredential],
                       using decryptor: DataLeakInformationDataDecryptor?) async throws {
        await self.fetchRemotePublicBreachesAndUpdateStore(for: credentials)
        try await fetchRemoteDataLeaksAndUpdateStore(for: credentials, using: decryptor)
    }
    
        func fetchPublicBreaches(for credentials: [SecurityDashboardCredential]) async {
        await fetchRemotePublicBreachesAndUpdateStore(for: credentials)
    }
    
                func fetchDataLeaks(for credentials: [SecurityDashboardCredential],
                        using decryptor: DataLeakInformationDataDecryptor?) async throws {
        try await fetchRemoteDataLeaksAndUpdateStore(for: credentials, using: decryptor)
    }
    
        private func fetchRemotePublicBreachesAndUpdateStore(for credentials: [SecurityDashboardCredential]) async {
        let latestRevision = self.breachesStore.lastRevisionForPublicBreaches
        let result = await self.fetcher.fetchBreaches(existingBreaches: self.cachedBreaches.value, userCredentials: credentials, latestRevision: latestRevision)
        self.breachesStore.lastRevisionForPublicBreaches = result.revision
        self.updateStoreAndCache(with: result.delta)
    }
    
        private func fetchRemoteDataLeaksAndUpdateStore(for credentials: [SecurityDashboardCredential],
                                                    using decryptor: DataLeakInformationDataDecryptor?) async throws {
        let lastUpdateDate = self.breachesStore.lastUpdateDateForDataLeakBreaches
        do {
            let leaksResult = try await self.fetcher.fetchDataLeaks(existingBreaches: self.cachedBreaches.value,
                                                                    decryptor: decryptor,
                                                                    userCredentials: credentials,
                                                                    lastUpdateDate: lastUpdateDate)
            self.dataLeaksUpdateFinished.send()
            self.breachesStore.lastUpdateDateForDataLeakBreaches = leaksResult.lastUpdateDate
            self.updateStoreAndCache(with: leaksResult.delta)
        } catch {
            self.dataLeaksUpdateFinished.send(completion: .failure(error))
            throw error
        }
    }
    
        static func treat(_ newBreaches: Set<StoredBreach>, comparingAgainst existingBreaches: Set<StoredBreach>, using credentials: [SecurityDashboardCredential]) -> DeltaUpdateBreaches {
        return BreachesFilter.delta(forOnlineBreaches: newBreaches, existingBreaches: existingBreaches, storedCredentials: credentials)
    }
    
        private func updateStoreAndCache(with delta: DeltaUpdateBreaches) {

        if !delta.inserted.isEmpty {
            self.log.debug("Will try to store \(delta.inserted.count) breaches - \(delta.inserted.map({ $0.breachID }))")
            self.breachesStore.create(delta.inserted)
        }

        if !delta.updated.isEmpty {
            self.log.debug("Will try to update \(delta.updated.count) breaches - \(delta.updated.map({ $0.breachID }))")
            self.breachesStore.update(delta.updated)
        }
    }

        private func pendingBreaches() -> Set<StoredBreach> {
        return Set(self.cachedBreaches.value.filter({ $0.status == .pending }).filter({ $0.breach.status != .deleted }))
    }
    
    private func pendingAndViewedBreaches() -> Set<StoredBreach> {
        return Set(self.cachedBreaches.value.filter({ $0.status == .pending || $0.status == .viewed }).filter({ $0.breach.status != .deleted }))
    }

    public func trayAlerts(for credentials: [String: [SecurityDashboardCredential]]) -> [TrayAlertProtocol] {
        self.pendingAndViewedBreaches().compactMap { storedBreach -> TrayAlertProtocol? in
            let compromisedCredentials = credentials[storedBreach.breach.id] ?? []
            return try? AlertGenerator.tray(for: storedBreach.breach,
                                               compromising: compromisedCredentials,
                                               leaking: storedBreach.leakedPasswords,
                                               requestInformation: self.alertsInformationProvider.requestInformation,
                                               localizationProvider: self.localization)
        }
    }

        public nonisolated func trayAlertsPublisher(breachPublisher: AnyPublisher<[StoredBreach], Never>) -> AnyPublisher<[TrayAlertProtocol], Never> {
        breachPublisher
            .combineLatest(cachedBreachCredentialsPublisher)
            .map { storedBreaches, cachedBreachesCredentials -> [TrayAlertProtocol] in
                storedBreaches
                    .filter { $0.status.isDisplayable && $0.breach.status != .deleted }
                    .compactMap { storedBreach -> TrayAlertProtocol? in
                    let credentials = cachedBreachesCredentials[storedBreach.breach.id] ?? []
                    return try? AlertGenerator.tray(for: storedBreach.breach,
                                                       compromising: credentials,
                                                       leaking: storedBreach.leakedPasswords,
                                                       requestInformation: self.alertsInformationProvider.requestInformation,
                                                       localizationProvider: self.localization)

                }
            }
            .eraseToAnyPublisher()
    }
    
        public nonisolated func popupAlertPublisher() -> AnyPublisher<[PopupAlertProtocol], Never> {
        self.cachedBreaches
            .combineLatest(cachedBreachCredentialsPublisher)
            .map { cachedBreaches, cachedBreachesCredentials -> [PopupAlertProtocol] in
                cachedBreaches
                    .filter { $0.status == .pending }
                    .filter { $0.breach.status != .deleted }
                    .compactMap { [weak self] cachedBreach -> PopupAlertProtocol? in
                        guard let self = self else { return nil }
                        let credentials = cachedBreachesCredentials[cachedBreach.breach.id] ?? []
                        return try? AlertGenerator.popup(for: cachedBreach.breach,
                                                            compromising: credentials,
                                                            leaking: cachedBreach.leakedPasswords,
                                                            requestInformation: self.alertsInformationProvider.requestInformation,
                                                            localizationProvider: self.localization)
                    }
            }.eraseToAnyPublisher()
    }

                            public func mark(breachIDs: [BreachesService.Identifier], as status: StoredBreach.Status) {
        self.log.debug("Marking \(breachIDs) as \(status)")
        
        let breachesToUpdate = self.cachedBreaches.value
            .filter({ breachIDs.contains($0.breachID) })
            .map({ StoredBreach(storedBreach: $0, status: status) })
        
        let delta = DeltaUpdateBreaches(inserted: [], updated: Set(breachesToUpdate))
        
        self.updateStoreAndCache(with: delta)
    }
}

private extension Sequence where Element == StoredBreach {
    func breachesByPasswords() -> [BreachesService.Password: Set<Breach>] {
        return reduce(into: [BreachesService.Password: Set<Breach>]()) { (result, storedBreach) in
            storedBreach.leakedPasswords.forEach({ password in
                guard !password.isEmpty else { return }
                _ = result[password, default: []].insert(storedBreach.breach)
            })
        }
    }
}


private extension StoredBreach.Status {
    var isDisplayable: Bool {
        return self == .pending || self == .viewed
    }
}
