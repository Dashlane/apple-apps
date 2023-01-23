import Foundation
import Combine
import CoreNetworking
import DashTypes
import CoreSession
import CoreSync
import DashlaneCrypto
import SwiftTreats
import CoreUserTracking
import CorePersonalData
import VaultKit


public class SyncService: Mockable {
    public enum Origin {
        case autofillExtension
        case safariExtension
        case app
        case authenticator
        
        var acceptedTypes: Set<PersonalDataContentType> {
            switch self {
            case .autofillExtension, .authenticator:
                return [.credential, .settings]
            case .app, .safariExtension:
                return Set(PersonalDataContentType.allCases)
            }
        }
        
        var maxConcurrentProcessCount: Int {
            switch self {
            case .autofillExtension:
                return 1
            case .app, .safariExtension, .authenticator:
                return ProcessInfo().processorCount
            }
        }
    }
    
    enum SyncStoreKey: String, StoreKey {
        case lastSyncTimestamp
    }
    
    public enum SyncStatus {
                case syncing
                case idle
                case offline
                case disabled
                case error(Error)
    }
    
    enum SyncError: Error {
        case alreadyInProgress
        case timeout
        case disabled
    }
    
    let syncEngine: SyncLoop<SyncDBStack>
    
        public var lastSync: Timestamp {
        get {
            store.retrieve()
        }
        set {
            do {
                try store.store(newValue)
            } catch {
                self.syncLogger.fatal("Failed to store last sync timestamp")
            }
        }
    }
    
    let database: SyncDBStack
    let activityReporter: ActivityReporterProtocol
    let store: BasicKeyedStore<SyncStoreKey>
    let syncLogger: Logger
    let target: BuildTarget
    let sharingKeysStore: SharingKeysStore
    
        @Published
    public var syncStatus: SyncStatus = .idle {
        didSet {
            if case .idle = syncStatus {
                lastTimeSyncTriggered = Date()
            }
        }
    }
    
        @Published
    public var lastTimeSyncTriggered = Date()
    
                private var cancellables = Set<AnyCancellable>()
    
    let executionQueue: DispatchQueue = DispatchQueue(label: "SyncServiceQueue", qos: .utility)
    var currentSyncTask: Task<Void, Error>? = nil
    
    @Atomic
    private var disableSync = false
    private let sharingHandler: SharingSyncHandler
        private var latestTrigger: Definition.Trigger?
    private let lock: DistributedLock
    private lazy var syncDispatcher = RateLimitingDispatcher(delayBetweenExecutions: 2.0,
                                                             queue: executionQueue,
                                                             lock: lock,
                                                             closure: { [weak self] completion in
        guard let self = self else {
            return
        }
        Task {
            do {
                try await self.sync()
                completion?()
                self.syncDidFinish(result: .success)
            } catch {
                self.syncDidFinish(result: .failure(error))
            }
        }
    })
            internal init(apiClient: DeprecatedCustomAPIClient,
                  databaseDriver: DatabaseDriver,
                  sharingKeysStore: SharingKeysStore,
                  remoteCryptoEngine: CryptoEngine,
                  sharingHandler: SharingSyncHandler,
                  activityReporter: ActivityReporterProtocol,
                  session: Session,
                  logger: Logger,
                  target: BuildTarget) throws {
        self.syncLogger = logger
        self.sharingHandler = sharingHandler
        self.activityReporter = activityReporter
        self.sharingKeysStore = sharingKeysStore
        
        database = SyncDBStack(driver: databaseDriver,
                               transactionCryptoEngine: remoteCryptoEngine,
                               historyUserInfo: HistoryUserInfo(session: session))
        
        syncEngine = SyncLoop(database: database,
                              sharingKeysStore: sharingKeysStore,
                              apiClient: apiClient,
                              logger: syncLogger)
        
        store = try BasicKeyedStore(persistenceEngine: session.lastSyncTimestampURL)
        
        self.target = target
        
        let lockURL = try session.directory.storeURL(for: .galactica, in: target).appendingPathComponent("lock")
        lock = DistributedLock(url: lockURL)
        
        setupSyncOnEvent(using: databaseDriver)
    }
    
    public func hasAlreadySync() -> Bool {
        return database.hasAlreadySync()
    }
    
        private func setupSyncOnEvent(using databaseDriver: DatabaseDriver) {
        NotificationCenter
            .default
            .didBecomeActiveNotificationPublisher()?
            .sink { [weak self] _ in
                self?.sync(triggeredBy: .wake)
            }.store(in: &cancellables)
        
        databaseDriver.syncTriggerPublisher.sink { [weak self] _ in
            self?.sync(triggeredBy: .save)
        }.store(in: &cancellables)
    }
    
        public func unload(_ completion: @escaping VoidCompletionBlock) {
        Task {
            await waitForCurrentSyncToFinish()
            cancellables.forEach { $0.cancel() }
            completion()
        }
    }
    
            public func sync(triggeredBy trigger: Definition.Trigger) {
        syncLogger.debug("dipatching a sync")
        self.latestTrigger = trigger
        syncDispatcher.dispatch()
    }
    
    private func sync() async throws {
        guard !disableSync else {
            syncLogger.warning("Sync is disabled!")
            throw SyncError.disabled
        }
        
        await waitForCurrentSyncToFinish()
        
        syncStatus = .syncing
        currentSyncTask = Task.detached(priority: .background) {
            try await self.performSync()
        }
        try await currentSyncTask?.value
        currentSyncTask = nil
    }
    
    private func waitForCurrentSyncToFinish() async {
        try? await currentSyncTask?.value
    }
    
        private func performSync() async throws  {
        let syncExtent: Definition.Extent = self.lastSync == 0 ? .initial : .light
        var summary: SharingSummaryInfo?
        
        do {
            let syncOutput = try await self.syncEngine.sync(from: lastSync, sharingSummary: &summary)
            self.lastSync = syncOutput.timestamp
            
            try? await self.sharingHandler.sync(using: summary)
            
            var trigger: Definition.Trigger
            if syncExtent == .initial {
                trigger = .initialLogin
            } else {
                trigger = self.latestTrigger ?? .periodic
            }
            self.activityReporter.reportSuccessfulSync(syncOutput.syncReport,
                                                       extent: syncExtent,
                                                       trigger: trigger)
            
        } catch {
            self.syncLogger.fatal("Sync did fail with error", error: error)
            
                        try? await self.sharingHandler.sync(using: summary)
            
            throw error
        }
    }
    
    private func syncDidFinish(result: Result<Void, Error>) {
        switch result {
        case .success():
            syncStatus = .idle
        case .failure(SyncLoopError.offline):
            syncStatus = .offline
        case .failure(SyncError.disabled):
            syncStatus = .disabled
        case .failure(SyncLoopError.unknownUserDevice):
            syncStatus = .error(SyncLoopError.unknownUserDevice)
        case let .failure(error):
            syncStatus = .error(error)
            syncLogger.fatal("Sync did fail with error", error: error)
        }
    }
}

extension SyncService {
        public func syncAndDisable(completion: @escaping (Result<Void, Error>) -> Void) {
        executionQueue.async { [weak self] in
            guard let self = self else { return }
            Task {
                do {
                    await self.waitForCurrentSyncToFinish()
                    try await self.performSync()
                    self.disableSync = true
                    completion(.success)
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func enableSync(triggeredBy trigger: Definition.Trigger) {
        self.disableSync = false
        sync(triggeredBy: trigger)
    }
}


extension SyncService {
        func load() async throws {
        let needKeys = await self.sharingKeysStore.needsKey
        if !self.database.hasAlreadySync() || needKeys {
            try await self.sync()
        } else {
            self.sync(triggeredBy: .login)
        }
    }
    
    public convenience init(apiClient: DeprecatedCustomAPIClient,
                            activityReporter: ActivityReporterProtocol,
                            sharingKeysStore: SharingKeysStore,
                            databaseDriver: DatabaseDriver,
                            sharingHandler: SharingSyncHandler,
                            session: Session,
                            syncLogger: Logger,
                            target: BuildTarget) async throws {
        try self.init(apiClient: apiClient,
                      databaseDriver: databaseDriver,
                      sharingKeysStore: sharingKeysStore,
                      remoteCryptoEngine: session.remoteCryptoEngine,
                      sharingHandler: sharingHandler,
                      activityReporter: activityReporter,
                      session: session,
                      logger: syncLogger,
                      target: target)
        try await self.load()
    }
}

extension KeyedStore where Key == SyncService.SyncStoreKey {
    func store(_ timestamp: Timestamp) throws {
        try store(timestamp.rawValue, for: .lastSyncTimestamp)
    }
    
    func retrieve() -> Timestamp {
        let lastSyncTimestamp: UInt64? = try? retrieve(for: .lastSyncTimestamp)
        return lastSyncTimestamp.flatMap {Timestamp.init($0)} ?? .distantPast
    }
}

extension Session {
    var lastSyncTimestampURL: URL {
        get throws {
            return try directory.storeURL(for: .galactica, in: .app)
                .appendingPathComponent(SyncService.SyncStoreKey.lastSyncTimestamp.rawValue)
        }
    }
}

extension BuildTarget {
    var maxConcurrentProcessCount: Int {
        switch self {
        case .tachyon:
            return 1
        case .app, .safari, .authenticator:
            return ProcessInfo().processorCount
        }
    }
}
