import Combine
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import VaultKit

enum AccountCryptoChangerError: Error {
  case encryptionError(AccountMigraterError)
  case syncFailed(Error)
}

enum AccountCryptoChangerState {
  case inProgress(AccountCryptoChangerService.Progression)
  case finished(Result<Session, AccountCryptoChangerError>)
}

protocol AccountCryptoChangerServiceProtocol: AnyObject {
  func start()
  var progressPublisher: PassthroughSubject<AccountCryptoChangerState, Never> { get }
}

class AccountCryptoChangerService: AccountCryptoChangerServiceProtocol {
  typealias Progression = EncryptionMigrater<EncryptionMigrationFinalizer>.Progression

  private var subscription: AnyCancellable?
  let progressPublisher = PassthroughSubject<AccountCryptoChangerState, Never>()
  let syncService: SyncServiceProtocol?
  let sessionCryptoUpdater: SessionCryptoUpdater?
  private let personalDataMigrationFinalizer: EncryptionMigrationFinalizer
  private let personalDataEncryptionMigrater: EncryptionMigrater<EncryptionMigrationFinalizer>

  var state: AccountCryptoChangerState = .inProgress(
    .downloading(.inProgress(completedFraction: 0)))
  {
    didSet {
      progressPublisher.send(state)
    }
  }

  init(
    mode: MigrationUploadMode = .masterKeyChange,
    reportedType: Definition.CryptoMigrationType,
    migratingSession: MigratingSession,
    syncService: SyncServiceProtocol?,
    sessionCryptoUpdater: SessionCryptoUpdater? = nil,
    activityReporter: ActivityReporterProtocol,
    sessionsContainer: SessionsContainerProtocol,
    databaseDriver: DatabaseDriver,
    postCryptoChangeHandler: PostAccountCryptoChangeHandler,
    apiClient: UserDeviceAPIClient,
    authTicket: CoreSync.AuthTicket? = nil,
    logger: Logger,
    cryptoSettings: CryptoRawConfig?
  ) throws {
    self.syncService = syncService
    self.sessionCryptoUpdater = sessionCryptoUpdater
    let activityReporter = AccountCryptoChangeActivityReporter(
      type: reportedType,
      migratingSession: migratingSession,
      activityReporter: activityReporter)
    personalDataMigrationFinalizer = EncryptionMigrationFinalizer(
      migratingSession: migratingSession,
      mode: mode,
      sessionsContainer: sessionsContainer,
      syncService: syncService,
      sessionCryptoUpdater: sessionCryptoUpdater,
      postCryptoChangeHandler: postCryptoChangeHandler,
      activityReporter: activityReporter)

    let cryptoEngine = CryptoChangerEngine(
      current: migratingSession.source.remoteCryptoEngine,
      new: migratingSession.target.remoteCryptoEngine)

    let remoteKeys = try migratingSession.target.encryptedRemoteKey()
      .map { encryptedKey in
        let isSSO = migratingSession.target.configuration.info.accountType == .sso
        return [
          SyncUploadDataRemoteKeys(
            uuid: UUID().uuidString.lowercased(),
            key: encryptedKey.base64EncodedString(),
            type: isSSO ? .sso : .masterPassword)
        ]
      }

    personalDataEncryptionMigrater = EncryptionMigrater(
      mode: mode,
      delegate: personalDataMigrationFinalizer,
      decryptEngine: cryptoEngine,
      encryptEngine: cryptoEngine,
      database: MigrationCryptoDBStack(driver: databaseDriver),
      apiClient: apiClient,
      authTicket: authTicket,
      remoteKeys: remoteKeys,
      cryptoSettings: cryptoSettings,
      logger: logger)
    subscription = personalDataMigrationFinalizer.progressPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: \.state, on: self)
  }

  func start() {
    Task {
      guard let syncService = syncService else {
        await self.personalDataEncryptionMigrater.start()
        return
      }
      do {
        try await syncService.syncAndDisable()
        self.sessionCryptoUpdater?.disable()
        await self.personalDataEncryptionMigrater.start()
      } catch {
        progressPublisher.send(.finished(.failure(.syncFailed(error))))
      }
    }
  }
}

final class EncryptionMigrationFinalizer: CoreSync.EncryptionMigraterDelegate {
  let migratingSession: MigratingSession
  let mode: MigrationUploadMode
  let sessionsContainer: SessionsContainerProtocol
  let syncService: SyncServiceProtocol?
  let postCryptoChangeHandler: PostAccountCryptoChangeHandler
  let activityReporter: AccountCryptoChangeActivityReporter
  let sessionCryptoUpdater: SessionCryptoUpdater?
  public let progressPublisher = PassthroughSubject<AccountCryptoChangerState, Never>()

  public init(
    migratingSession: MigratingSession,
    mode: MigrationUploadMode,
    sessionsContainer: SessionsContainerProtocol,
    syncService: SyncServiceProtocol?,
    sessionCryptoUpdater: SessionCryptoUpdater?,
    postCryptoChangeHandler: PostAccountCryptoChangeHandler,
    activityReporter: AccountCryptoChangeActivityReporter
  ) {
    self.migratingSession = migratingSession
    self.mode = mode
    self.sessionsContainer = sessionsContainer
    self.syncService = syncService
    self.sessionCryptoUpdater = sessionCryptoUpdater
    self.postCryptoChangeHandler = postCryptoChangeHandler
    self.activityReporter = activityReporter
  }

  func complete(
    with timestamp: DashTypes.Timestamp,
    completionHandler: @escaping @MainActor (
      Result<CoreSession.Session, Error>
    ) async -> Void
  ) {
    Task {
      let result = Result<Session, Error> {
        let session = try self.sessionsContainer.finalizeMigration(using: self.migratingSession)
        try self.postCryptoChangeHandler.handle(session, syncTimestamp: timestamp)
        return session
      }
      await completionHandler(result)
    }
  }

  func didProgress(_ progression: EncryptionMigrater<EncryptionMigrationFinalizer>.Progression) {
    progressPublisher.send(.inProgress(progression))
  }

  func didFinish(with result: AccountMigrationResult) {
    if result.isFailure || mode == .cryptoConfigChange {
      self.syncService?.enableSync(triggeredBy: .settingsChange)
      self.sessionCryptoUpdater?.enable()
    }
    activityReporter.report(result)
    progressPublisher.send(.finished(result.mapError { .encryptionError($0) }))
  }
}

typealias AccountMigraterError = EncryptionMigrater<EncryptionMigrationFinalizer>.MigraterError
typealias AccountMigrationResult = Result<Session, AccountMigraterError>

extension AccountCryptoChangerService {
  class FakeAccountCryptoChangerService: AccountCryptoChangerServiceProtocol {
    func start() {}

    var progressPublisher = PassthroughSubject<AccountCryptoChangerState, Never>()
  }

  static var mock: AccountCryptoChangerServiceProtocol {
    FakeAccountCryptoChangerService()
  }
}
