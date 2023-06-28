import Foundation
import Combine
import CoreUserTracking
import DashlaneAppKit
import CorePasswords
import CoreSession
import CoreSync
import DashTypes
import CorePersonalData
import CoreNetworking
import LoginKit
import CoreKeychain
import CorePremium

final class ChangeMasterPasswordFlowViewModel: ObservableObject, SessionServicesInjecting {

    enum Step {
        case intro
        case updateMasterPassword(NewMasterPasswordViewModel)
        case passwordMigrationProgression(MigrationProgressViewModel)
    }

    let session: Session
    let sessionsContainer: SessionsContainerProtocol
    let premiumService: PremiumServiceProtocol
    let passwordEvaluator: PasswordEvaluatorProtocol
    let logger: Logger
    let activityReporter: ActivityReporterProtocol
    let syncService: SyncServiceProtocol
    let apiClient: DeprecatedCustomAPIClient
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let keychainService: AuthenticationKeychainServiceProtocol
    let sessionCryptoUpdater: SessionCryptoUpdater
    let databaseDriver: DatabaseDriver
    let sessionLifeCycleHandler: SessionLifeCycleHandler?

    private var accountCryptoChangerService: AccountCryptoChangerService?

    @Published
    var steps: [Step] = [.intro]

    var isSyncEnabled: Bool {
       return premiumService.capability(for: \.sync).enabled
    }

    let dismissPublisher = PassthroughSubject<Void, Never>()
    let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory

    init(session: Session, sessionsContainer: SessionsContainerProtocol, premiumService: PremiumServiceProtocol,
         passwordEvaluator: PasswordEvaluatorProtocol, logger: Logger, activityReporter: ActivityReporterProtocol, syncService: SyncServiceProtocol,
         apiClient: DeprecatedCustomAPIClient, resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         keychainService: AuthenticationKeychainServiceProtocol, sessionCryptoUpdater: SessionCryptoUpdater,
         databaseDriver: DatabaseDriver, sessionLifeCycleHandler: SessionLifeCycleHandler?, migrationProgressViewModelFactory: MigrationProgressViewModel.Factory) {
        self.session = session
        self.sessionsContainer = sessionsContainer
        self.premiumService = premiumService
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
        let viewModel = NewMasterPasswordViewModel(mode: .masterPasswordChange,
                                                   evaluator: passwordEvaluator,
                                                   keychainService: keychainService,
                                                   login: session.login,
                                                   activityReporter: activityReporter) { [weak self] result in
            switch result {
            case .back:
                self?.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .cancel))
                self?.dismissPublisher.send()
            case let .next(masterPassword: masterPassword):
                self?.startChangingMasterPassword(with: masterPassword)
            }
        }

        steps.append(.updateMasterPassword(viewModel))
    }

    private func startChangingMasterPassword(with masterPassword: String) {

        do {
            accountCryptoChangerService = try createMasterPasswordChangerService(withNewMasterPassword: masterPassword)
            let viewModel = migrationProgressViewModelFactory.make(type: .masterPasswordToMasterPassword,
                                                                   accountCryptoChangerService: accountCryptoChangerService!,
                                                                   context: .changeMP) { [weak self] result in
                if case .success(let session) = result {
                    self?.sessionLifeCycleHandler?.logoutAndPerform(action: .startNewSession(session, reason: .masterPasswordChanged))
                } else {
                    self?.dismissPublisher.send()
                }
            }
            steps.append(.passwordMigrationProgression(viewModel))
            accountCryptoChangerService!.start()
        } catch {
            dismissPublisher.send()
        }
    }

    private func createMasterPasswordChangerService(withNewMasterPassword newMasterPassword: String) throws -> AccountCryptoChangerService {
        let cryptoConfig = CryptoRawConfig.masterPasswordBasedDefault
        let currentMasterKey = session.authenticationMethod.sessionKey

        let migratingSession = try sessionsContainer.prepareMigration(of: session,
                                                                      to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey),
                                                                      remoteKey: nil,
                                                                      cryptoConfig: cryptoConfig,
                                                                      accountMigrationType: .masterPasswordToMasterPassword,
                                                                      loginOTPOption: session.configuration.info.loginOTPOption)

        let postCryptoChangeHandler = PostMasterKeyChangerHandler(keychainService: keychainService,
                                                                  resetMasterPasswordService: resetMasterPasswordService,
                                                                  syncService: syncService)

        let reportedType: Definition.CryptoMigrationType = migratingSession.source.configuration.info.accountType == .sso ? .ssoToMasterPassword : .masterPasswordChange
        return try AccountCryptoChangerService(reportedType: reportedType,
                                               migratingSession: migratingSession,
                                               syncService: syncService,
                                               sessionCryptoUpdater: sessionCryptoUpdater,
                                               activityReporter: activityReporter,
                                               sessionsContainer: sessionsContainer,
                                               databaseDriver: databaseDriver,
                                               postCryptoChangeHandler: postCryptoChangeHandler,
                                               apiNetworkingEngine: apiClient,
                                               logger: logger,
                                               cryptoSettings: cryptoConfig)
    }
}

extension ChangeMasterPasswordFlowViewModel {

    static var mock: ChangeMasterPasswordFlowViewModel {
        ChangeMasterPasswordFlowViewModel(session: .mock,
                                          sessionsContainer: SessionsContainer<InMemorySessionStoreProvider>.mock,
                                          premiumService: PremiumServiceMock(),
                                          passwordEvaluator: .mock(),
                                          logger: LoggerMock(),
                                          activityReporter: .fake,
                                          syncService: SyncServiceMock(),
                                          apiClient: .fake,
                                          resetMasterPasswordService: ResetMasterPasswordServiceMock(),
                                          keychainService: .fake,
                                          sessionCryptoUpdater: SessionCryptoUpdater.mock,
                                          databaseDriver: InMemoryDatabaseDriver(),
                                          sessionLifeCycleHandler: nil,
                                          migrationProgressViewModelFactory: .init({ _, _, _, _, _, _ in .mock() }))
    }
}
