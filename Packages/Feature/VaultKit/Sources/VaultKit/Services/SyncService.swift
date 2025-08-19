import Combine
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreSync
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation

public protocol SyncServiceProtocol {
  var lastSync: Timestamp { get nonmutating set }
  var syncStatus: SyncService.SyncStatus { get set }
  var syncStatusPublisher: AnyPublisher<SyncService.SyncStatus, Never> { get }

  var lastTimeSyncTriggered: Date { get set }

  func hasAlreadySync() -> Bool
  func unload() async

  func sync(triggeredBy trigger: Definition.Trigger)
  func sync() async throws

  func syncAndDisable() async throws
  func enableSync(triggeredBy trigger: Definition.Trigger)
}

public class SyncService: SyncServiceProtocol {
  public enum Origin {
    case autofillExtension
    case app

    var acceptedTypes: Set<PersonalDataContentType> {
      switch self {
      case .autofillExtension:
        return [.credential, .settings]
      case .app:
        return Set(PersonalDataContentType.allCases)
      }
    }

    var maxConcurrentProcessCount: Int {
      switch self {
      case .autofillExtension:
        return 1
      case .app:
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

  @Loggable
  enum SyncServiceError: Error {
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
  let store: BasicKeyedStore<SyncStoreKey>
  let syncLogger: Logger
  let target: BuildTarget
  let sharingKeysStore: SharingKeysStore
  let loadingContext: SessionLoadingContext

  @Published
  public var syncStatus: SyncStatus = .idle {
    didSet {
      if case .idle = syncStatus {
        lastTimeSyncTriggered = Date()
      }
    }
  }

  public var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
    return $syncStatus.eraseToAnyPublisher()
  }

  @Published
  public var lastTimeSyncTriggered = Date()

  private var cancellables = Set<AnyCancellable>()

  let executionQueue: DispatchQueue = DispatchQueue(label: "SyncServiceQueue", qos: .utility)
  var currentSyncTask: Task<Void, Error>?

  @Atomic
  private var disableSync = false
  private var sharingHandler: SharingSyncHandler
  private var latestTrigger: Definition.Trigger
  private let lock: DistributedLock
  private lazy var syncDispatcher = RateLimitingDispatcher(
    delayBetweenExecutions: 2.0,
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
  internal init(
    apiClient: UserDeviceAPIClient,
    databaseDriver: DatabaseDriver,
    sharingKeysStore: SharingKeysStore,
    remoteCryptoEngine: CryptoEngine,
    sharingHandler: SharingSyncHandler,
    session: Session,
    loadingContext: SessionLoadingContext,
    logger: Logger,
    target: BuildTarget
  ) throws {
    self.syncLogger = logger
    self.sharingHandler = sharingHandler
    self.sharingKeysStore = sharingKeysStore
    self.loadingContext = loadingContext
    self.latestTrigger =
      switch loadingContext {
      case .accountCreation:
        .accountCreation
      case .localLogin:
        .login
      case .remoteLogin:
        .initialLogin
      }

    database = SyncDBStack(
      driver: databaseDriver,
      transactionCryptoEngine: remoteCryptoEngine,
      historyUserInfo: HistoryUserInfo(session: session)
    )

    syncEngine = SyncLoop(
      database: database,
      sharingKeysStore: sharingKeysStore,
      apiClient: apiClient,
      shouldTreatProblems: !target.hasLimitedSyncCapabilities,
      shouldHandleSharingKeys: !target.hasLimitedSyncCapabilities,
      shouldParallelize: !target.hasLimitedSyncCapabilities && !SafeMode.isEnabled,
      logger: syncLogger
    )

    store = try BasicKeyedStore(persistenceEngine: session.lastSyncTimestampURL)

    self.target = target

    let lockURL = try session.directory.storeURL(for: .galactica, in: target)
      .appendingPathComponent("lock")
    lock = DistributedLock(id: target.rawValue, url: lockURL)

    setupSyncOnEvent(using: databaseDriver)
    self.sharingHandler.manualSyncHandler = { [weak self] in self?.sync(triggeredBy: .manual) }
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

  public func unload() async {
    await waitForCurrentSyncToFinish()
    cancellables.forEach { $0.cancel() }
  }

  public func sync(triggeredBy trigger: Definition.Trigger) {
    syncLogger.debug("dipatching a sync triggered by \(trigger)")
    self.latestTrigger = trigger
    syncDispatcher.dispatch()
  }

  public func sync() async throws {
    guard !disableSync else {
      syncLogger.warning("Sync is disabled!")
      throw SyncServiceError.disabled
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

  private func performSync() async throws {
    var summary: SharingSummaryInfo?

    do {
      let shouldWaitUnlock = loadingContext.isAccountCreation && lastSync == 0

      let syncOutput = try await self.syncEngine.sync(
        from: lastSync,
        waitServerUnlock: shouldWaitUnlock,
        sharingSummary: &summary)
      self.lastSync = syncOutput.timestamp
      try? await self.sharingHandler.sync(using: summary)

    } catch {
      try? await self.sharingHandler.sync(using: summary)

      throw error
    }
  }

  private func syncDidFinish(result: Result<Void, Error>) {
    switch result {
    case .success:
      syncStatus = .idle
    case .failure(SyncError.offline):
      syncStatus = .offline
    case .failure(SyncServiceError.disabled):
      syncStatus = .disabled
    case .failure(SyncError.unknownUserDevice):
      syncStatus = .error(SyncError.unknownUserDevice)
    case let .failure(error):
      syncStatus = .error(error)
      syncLogger.fatal("Sync did fail with error", error: error)
    }
  }
}

extension SyncService {
  public func syncAndDisable() async throws {
    try await self.sync()
    self.disableSync = true
  }

  public func enableSync(triggeredBy trigger: Definition.Trigger) {
    self.disableSync = false
    sync(triggeredBy: trigger)
  }
}

extension SyncService {
  func load(shouldDelay: Bool = false) async throws {
    if shouldDelay {

    }
    let needKeys = await self.sharingKeysStore.needsKey
    if !self.database.hasAlreadySync() || needKeys {
      try await self.sync()
    } else {
      self.sync(triggeredBy: .login)
    }
  }

  public convenience init(
    apiClient: UserDeviceAPIClient,
    sharingKeysStore: SharingKeysStore,
    databaseDriver: DatabaseDriver,
    sharingHandler: SharingSyncHandler,
    session: Session,
    loadingContext: SessionLoadingContext,
    syncLogger: Logger,
    target: BuildTarget
  ) async throws {
    try self.init(
      apiClient: apiClient,
      databaseDriver: databaseDriver,
      sharingKeysStore: sharingKeysStore,
      remoteCryptoEngine: session.remoteCryptoEngine,
      sharingHandler: sharingHandler,
      session: session,
      loadingContext: loadingContext,
      logger: syncLogger,
      target: target
    )

    try await self.load()
  }
}

extension KeyedStore where Key == SyncService.SyncStoreKey {
  func store(_ timestamp: Timestamp) throws {
    try store(timestamp.rawValue, for: .lastSyncTimestamp)
  }

  func retrieve() -> Timestamp {
    let lastSyncTimestamp: UInt64? = try? retrieve(for: .lastSyncTimestamp)
    return lastSyncTimestamp.flatMap { Timestamp.init($0) } ?? .distantPast
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
  var hasLimitedSyncCapabilities: Bool {
    switch self {
    case .tachyon:
      return true
    case .app:
      return false
    }
  }
}
