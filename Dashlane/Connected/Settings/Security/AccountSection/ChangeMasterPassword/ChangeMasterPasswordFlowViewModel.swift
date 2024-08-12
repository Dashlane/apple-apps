import Combine
import CoreKeychain
import CoreNetworking
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import VaultKit

@MainActor
final class ChangeMasterPasswordFlowViewModel: ObservableObject, SessionServicesInjecting {

  enum Step {
    case intro
    case updateMasterPassword
    case passwordMigrationProgression
  }

  let session: Session
  let sessionsContainer: SessionsContainerProtocol
  let capabilityService: CapabilityServiceProtocol
  let passwordEvaluator: PasswordEvaluatorProtocol
  let logger: Logger
  let activityReporter: ActivityReporterProtocol
  let syncService: SyncServiceProtocol
  let apiClient: UserDeviceAPIClient
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let keychainService: AuthenticationKeychainServiceProtocol
  let sessionCryptoUpdater: SessionCryptoUpdater
  let databaseDriver: DatabaseDriver
  let sessionLifeCycleHandler: SessionLifeCycleHandler?

  private var accountCryptoChangerService: AccountCryptoChangerService?

  @Published
  var steps: [Step] = [.intro]

  var isSyncEnabled: Bool {
    return capabilityService.status(of: .sync).isAvailable
  }

  let dismissPublisher = PassthroughSubject<Void, Never>()
  let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory

  init(
    session: Session,
    sessionsContainer: SessionsContainerProtocol,
    capabilityService: CapabilityServiceProtocol,
    passwordEvaluator: PasswordEvaluatorProtocol,
    logger: Logger,
    activityReporter: ActivityReporterProtocol,
    syncService: SyncServiceProtocol,
    apiClient: UserDeviceAPIClient,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    sessionCryptoUpdater: SessionCryptoUpdater,
    databaseDriver: DatabaseDriver,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    migrationProgressViewModelFactory: MigrationProgressViewModel.Factory
  ) {
    self.session = session
    self.sessionsContainer = sessionsContainer
    self.capabilityService = capabilityService
    self.passwordEvaluator = passwordEvaluator
    self.logger = logger
    self.activityReporter = activityReporter
    self.syncService = syncService
    self.apiClient = apiClient
    self.resetMasterPasswordService = resetMasterPasswordService
    self.keychainService = keychainService
    self.sessionCryptoUpdater = sessionCryptoUpdater
    self.databaseDriver = databaseDriver
    self.sessionLifeCycleHandler = sessionLifeCycleHandler
    self.migrationProgressViewModelFactory = migrationProgressViewModelFactory
  }

  func updateMasterPassword() {
    steps.append(.updateMasterPassword)
  }

  private func startChangingMasterPassword(with masterPassword: String) {
    do {
      accountCryptoChangerService = try createMasterPasswordChangerService(
        withNewMasterPassword: masterPassword)
      steps.append(.passwordMigrationProgression)
      accountCryptoChangerService!.start()
    } catch {
      dismissPublisher.send()
    }
  }

  private func createMasterPasswordChangerService(withNewMasterPassword newMasterPassword: String)
    throws -> AccountCryptoChangerService
  {
    let cryptoConfig = CryptoRawConfig.masterPasswordBasedDefault
    let currentMasterKey = session.authenticationMethod.sessionKey

    let migratingSession = try sessionsContainer.prepareMigration(
      of: session,
      to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey),
      remoteKey: nil,
      cryptoConfig: cryptoConfig,
      accountMigrationType: .masterPasswordToMasterPassword,
      loginOTPOption: session.configuration.info.loginOTPOption)

    let postCryptoChangeHandler = PostMasterKeyChangerHandler(
      keychainService: keychainService,
      resetMasterPasswordService: resetMasterPasswordService,
      syncService: syncService)

    let reportedType: Definition.CryptoMigrationType =
      migratingSession.source.configuration.info.accountType == .sso
      ? .ssoToMasterPassword : .masterPasswordChange
    return try AccountCryptoChangerService(
      reportedType: reportedType,
      migratingSession: migratingSession,
      syncService: syncService,
      sessionCryptoUpdater: sessionCryptoUpdater,
      activityReporter: activityReporter,
      sessionsContainer: sessionsContainer,
      databaseDriver: databaseDriver,
      postCryptoChangeHandler: postCryptoChangeHandler,
      apiClient: apiClient,
      logger: logger,
      cryptoSettings: cryptoConfig)
  }
}

extension ChangeMasterPasswordFlowViewModel {
  func makeNewMasterPasswordViewModel() -> NewMasterPasswordViewModel {
    NewMasterPasswordViewModel(
      mode: .masterPasswordChange,
      evaluator: passwordEvaluator,
      keychainService: keychainService,
      login: session.login,
      activityReporter: activityReporter
    ) { [weak self] result in
      switch result {
      case .back:
        self?.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .cancel))
        self?.dismissPublisher.send()
      case let .next(masterPassword: masterPassword):
        self?.startChangingMasterPassword(with: masterPassword)
      }
    }
  }

  func makeMigrationProgressViewModel() -> MigrationProgressViewModel {
    migrationProgressViewModelFactory.make(
      type: .masterPasswordToMasterPassword,
      accountCryptoChangerService: accountCryptoChangerService!,
      context: .changeMP
    ) { [weak self] result in
      if case .success(let session) = result {
        self?.sessionLifeCycleHandler?.logoutAndPerform(
          action: .startNewSession(session, reason: .masterPasswordChanged))
      } else {
        self?.dismissPublisher.send()
      }
    }
  }
}

extension ChangeMasterPasswordFlowViewModel {

  static var mock: ChangeMasterPasswordFlowViewModel {
    ChangeMasterPasswordFlowViewModel(
      session: .mock,
      sessionsContainer: SessionsContainer<InMemorySessionStoreProvider>.mock,
      capabilityService: .mock(),
      passwordEvaluator: .mock(),
      logger: LoggerMock(),
      activityReporter: .mock,
      syncService: .mock(),
      apiClient: .fake,
      resetMasterPasswordService: ResetMasterPasswordServiceMock(),
      keychainService: .fake,
      sessionCryptoUpdater: SessionCryptoUpdater.mock,
      databaseDriver: InMemoryDatabaseDriver(),
      sessionLifeCycleHandler: nil,
      migrationProgressViewModelFactory: .init({ _, _, _, _, _, _ in .mock() }))
  }
}
