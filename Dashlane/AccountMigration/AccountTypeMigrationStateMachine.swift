import CorePersonalData
import CoreSession
import CoreSync
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import VaultKit

struct AccountTypeMigrationStateMachine: StateMachine, SessionServicesInjecting {
  typealias Progress = EncryptionMigrater.Progression
  typealias ProgressStream = AsyncStream<Progress>
  typealias Reason = UserDeviceAPIClient.Accountrecovery.Deactivate.Body.Reason

  enum State: Hashable {
    case initial
    case complete(Session)
    case failed(StateMachineError)
  }

  enum Event {
    case migrate(Reason, ProgressStream.Continuation)
  }

  var state: State = .initial

  private let accountCryptoChangerServiceFactory: AccountCryptoChangerService.Factory
  private let accountMigrationConfiguration: AccountMigrationConfiguration
  private let sessionsContainer: SessionsContainerProtocol
  private let syncService: SyncServiceProtocol?
  private let sessionCryptoUpdater: SessionCryptoUpdater?
  private let databaseDriver: DatabaseDriver
  private let apiClient: UserDeviceAPIClient
  private let logger: Logger
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  private let accountRecoveryKeyService: AccountRecoveryKeySetupService

  init(
    accountCryptoChangerServiceFactory: AccountCryptoChangerService.Factory,
    accountMigrationConfiguration: AccountMigrationConfiguration,
    sessionsContainer: SessionsContainerProtocol,
    syncService: SyncServiceProtocol?,
    sessionCryptoUpdater: SessionCryptoUpdater?,
    databaseDriver: DatabaseDriver,
    apiClient: UserDeviceAPIClient,
    logger: Logger,
    keychainService: AuthenticationKeychainServiceProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    accountRecoveryKeyService: AccountRecoveryKeySetupService
  ) {
    self.accountCryptoChangerServiceFactory = accountCryptoChangerServiceFactory
    self.accountMigrationConfiguration = accountMigrationConfiguration
    self.sessionsContainer = sessionsContainer
    self.syncService = syncService
    self.sessionCryptoUpdater = sessionCryptoUpdater
    self.databaseDriver = databaseDriver
    self.apiClient = apiClient
    self.logger = logger[.session]
    self.keychainService = keychainService
    self.resetMasterPasswordService = resetMasterPasswordService
    self.accountRecoveryKeyService = accountRecoveryKeyService
  }

  mutating func transition(with event: Event) async throws {
    switch event {
    case .migrate(let reason, let continuation):
      do {
        let session = try await performMigration(reason: reason) {
          continuation.yield($0)
        }
        self.state = .complete(session)
      } catch {
        enableSync()
        self.state = .failed(StateMachineError(underlyingError: error))
      }
      continuation.finish()
    }
  }

  private mutating func performMigration(
    reason: Reason, progressBlock: @escaping (Progress) -> Void
  ) async throws -> Session {
    let migratingSession = try sessionsContainer.prepareMigration(
      of: accountMigrationConfiguration.session,
      to: accountMigrationConfiguration.masterKey,
      remoteKey: accountMigrationConfiguration.remoteKey,
      cryptoConfig: accountMigrationConfiguration.cryptoConfig,
      loginOTPOption: accountMigrationConfiguration.loginOTPOption
    )

    try await disableSync()

    let encryptionMigrater = try makeEncryptionMigrater(
      migratingSession: migratingSession, databaseDriver: databaseDriver)
    let cancellable = encryptionMigrater.progressionPublisher.sink(receiveValue: progressBlock)

    let timestamp = try await encryptionMigrater.startMigration()
    let session = try sessionsContainer.finalizeMigration(using: migratingSession)
    try finalize(session, syncTimestamp: timestamp)
    try await encryptionMigrater.completeMigration()
    try await accountRecoveryKeyService.deactivateAccountRecoveryKey(for: reason)
    cancellable.cancel()

    return session
  }

  private func disableSync() async throws {
    sessionCryptoUpdater?.disable()
    if let syncService {
      try await syncService.syncAndDisable()
    }
  }

  private func makeEncryptionMigrater(
    migratingSession: MigratingSession,
    databaseDriver: DatabaseDriver
  ) throws -> EncryptionMigrater {
    let cryptoEngine = CryptoChangerEngine(
      current: migratingSession.source.remoteCryptoEngine,
      new: migratingSession.target.remoteCryptoEngine
    )

    let remoteKeys = try migratingSession.target.encryptedRemoteKey().map { encryptedKey in
      let isSSO = migratingSession.target.configuration.info.accountType == .sso
      return SyncUploadDataRemoteKeys(
        uuid: UUID().uuidString.lowercased(),
        key: encryptedKey.base64EncodedString(),
        type: isSSO ? .sso : .masterPassword
      )
    }

    return EncryptionMigrater(
      mode: .masterKeyChange,
      cryptoEngine: cryptoEngine,
      database: MigrationCryptoDBStack(driver: databaseDriver),
      apiClient: apiClient,
      authTicket: accountMigrationConfiguration.authTicket,
      remoteKeys: remoteKeys,
      cryptoSettings: migratingSession.target.cryptoConfig,
      logger: logger
    )
  }

  func finalize(_ session: Session, syncTimestamp: Timestamp) throws {
    let masterKeyStatus = keychainService.masterKeyStatus(for: session.login)
    if case .available(accessMode: let accessMode) = masterKeyStatus {
      try? keychainService.save(
        session.authenticationMethod.sessionKey.keyChainMasterKey,
        for: session.login,
        expiresAfter: keychainService.defaultPasswordValidityPeriod,
        accessMode: accessMode
      )
    }

    #if !targetEnvironment(simulator)
      if let newMasterPassword = session.authenticationMethod.userMasterPassword {
        try resetMasterPasswordService.update(masterPassword: newMasterPassword)
      }
    #endif
    syncService?.lastSync = syncTimestamp
  }

  private func enableSync() {
    sessionCryptoUpdater?.enable()
    if let syncService {
      syncService.enableSync(triggeredBy: .changeMasterPassword)
    }
  }
}

extension AccountTypeMigrationStateMachine {
  static func mock(accountMigrationConfiguration: AccountMigrationConfiguration) -> Self {
    AccountTypeMigrationStateMachine(
      accountCryptoChangerServiceFactory: .mock,
      accountMigrationConfiguration: accountMigrationConfiguration,
      sessionsContainer: .mock,
      syncService: .mock(),
      sessionCryptoUpdater: .mock,
      databaseDriver: InMemoryDatabaseDriver(),
      apiClient: .fake,
      logger: .mock,
      keychainService: .mock,
      resetMasterPasswordService: .mock,
      accountRecoveryKeyService: .mock
    )
  }
}
