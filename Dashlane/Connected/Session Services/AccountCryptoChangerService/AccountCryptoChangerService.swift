import Combine
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreSync
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import LoginKit
import UserTrackingFoundation
import VaultKit

@Loggable
enum AccountCryptoChangerError: Error {
  case encryptionError(EncryptionMigrater.MigrationError)
  case syncFailed(Error)
  case finalizationFailed(Error)
}

@Loggable
enum AccountCryptoChangerState {
  case inProgress(AccountCryptoChangerService.Progression)
  case completed(Session)
  case failed(AccountCryptoChangerError)
}

class AccountCryptoChangerService: SessionServicesInjecting {
  typealias Progression = EncryptionMigrater.Progression

  private var subscription: AnyCancellable?
  let progressPublisher = PassthroughSubject<AccountCryptoChangerState, Never>()
  private let syncService: SyncServiceProtocol?
  private let sessionCryptoUpdater: SessionCryptoUpdater?
  private let personalDataEncryptionMigrater: EncryptionMigrater
  private let activityReporter: AccountCryptoChangeActivityReporter
  private let migrationMode: MigrationUploadMode
  private let sessionsContainer: SessionsContainerProtocol
  private let migratingSession: MigratingSession
  private let postCryptoChangeHandler: PostAccountCryptoChangeHandler

  init(
    mode: MigrationUploadMode,
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
    self.migrationMode = mode
    self.activityReporter = AccountCryptoChangeActivityReporter(
      type: reportedType,
      migratingSession: migratingSession,
      activityReporter: activityReporter
    )
    self.sessionsContainer = sessionsContainer
    self.migratingSession = migratingSession
    self.postCryptoChangeHandler = postCryptoChangeHandler

    let cryptoEngine = CryptoChangerEngine(
      current: migratingSession.source.remoteCryptoEngine,
      new: migratingSession.target.remoteCryptoEngine)

    let remoteKeys = try migratingSession.target.encryptedRemoteKey().map { encryptedKey in
      let isSSO = migratingSession.target.configuration.info.accountType == .sso
      return SyncUploadDataRemoteKeys(
        uuid: UUID().uuidString.lowercased(),
        key: encryptedKey.base64EncodedString(),
        type: isSSO ? .sso : .masterPassword
      )
    }

    personalDataEncryptionMigrater = EncryptionMigrater(
      mode: mode,
      cryptoEngine: cryptoEngine,
      database: MigrationCryptoDBStack(driver: databaseDriver),
      apiClient: apiClient,
      authTicket: authTicket,
      remoteKeys: remoteKeys,
      cryptoSettings: cryptoSettings,
      logger: logger[.session]
    )

    subscription = personalDataEncryptionMigrater.progressionPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] progression in
        self?.progressPublisher.send(.inProgress(progression))
      }
  }

  func start() {
    Task {
      do {
        try await disableSync()
        let timestamp = try await self.personalDataEncryptionMigrater.startMigration()
        let session = try finalize(with: timestamp)
        try await self.personalDataEncryptionMigrater.completeMigration()
        complete(with: session)
      } catch let error as EncryptionMigrater.MigrationError {
        fail(with: .encryptionError(error))
      } catch let error as AccountCryptoChangerError {
        fail(with: error)
      }
    }
  }

  private func disableSync() async throws(AccountCryptoChangerError) {
    guard let syncService else { return }

    do {
      try await syncService.syncAndDisable()
      sessionCryptoUpdater?.disable()
    } catch {
      let error: AccountCryptoChangerError = .syncFailed(error)
      progressPublisher.send(.failed(error))
      throw error
    }
  }

  private func enableSync() {
    guard let syncService else { return }

    syncService.enableSync(triggeredBy: .settingsChange)
    sessionCryptoUpdater?.enable()
  }

  private func finalize(with timestamp: Timestamp) throws(AccountCryptoChangerError) -> Session {
    do {
      let session = try sessionsContainer.finalizeMigration(using: migratingSession)
      try postCryptoChangeHandler.handle(session, syncTimestamp: timestamp)
      return session
    } catch {
      throw .finalizationFailed(error)
    }
  }

  private func complete(with session: Session) {
    if migrationMode != .masterKeyChange {
      enableSync()
    }

    activityReporter.report(.success)
    progressPublisher.send(.completed(session))
  }

  private func fail(with error: AccountCryptoChangerError) {
    enableSync()
    activityReporter.report(error)
    progressPublisher.send(.failed(error))
  }
}

extension AccountCryptoChangerService.Factory {
  static var mock: Self {
    InjectedFactory {
      try AccountCryptoChangerService(
        mode: $0,
        reportedType: $1,
        migratingSession: $2,
        syncService: .mock(),
        activityReporter: .mock,
        sessionsContainer: .mock,
        databaseDriver: InMemoryDatabaseDriver(),
        postCryptoChangeHandler: $3,
        apiClient: .mock(using: .init()),
        authTicket: $4,
        logger: .mock,
        cryptoSettings: $5
      )
    }
  }
}
