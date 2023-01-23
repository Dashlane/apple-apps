import Foundation
import DashTypes
import CoreSync
import DashlaneCrypto
import CoreNetworking
import CoreSession
import CoreUserTracking
import DashlaneAppKit
import CorePersonalData

enum AccountCryptoChangerError: Error {
    case encryptionError(AccountMigraterError)
    case syncFailed(Error)
}

protocol AccountCryptoChangerServiceDelegate: AnyObject {
    func didProgress(_ progression: AccountCryptoChangerService.Progression)
    func didFinish(with result: Result<Session, AccountCryptoChangerError>)
}

class AccountCryptoChangerService {
    typealias Progression = EncryptionMigrater<EncryptionMigrationFinalizer>.Progression

    weak var delegate: AccountCryptoChangerServiceDelegate? {
        get {
            personalDataMigrationFinalizer.delegate
        } set {
            personalDataMigrationFinalizer.delegate = newValue
        }
    }

    let syncService: SyncServiceProtocol?
    let sessionCryptoUpdater: SessionCryptoUpdater?
    private let personalDataMigrationFinalizer: EncryptionMigrationFinalizer
    private let personalDataEncryptionMigrater: EncryptionMigrater<EncryptionMigrationFinalizer>

    init(mode: MigrationUploadMode = .masterKeyChange,
         reportedType: Definition.CryptoMigrationType,
         migratingSession: MigratingSession,
         syncService: SyncServiceProtocol?,
         sessionCryptoUpdater: SessionCryptoUpdater? = nil,
         activityReporter: ActivityReporterProtocol,
         sessionsContainer: SessionsContainerProtocol,
         databaseDriver: DatabaseDriver,
         postCryptoChangeHandler: PostAccountCryptoChangeHandler,
         apiNetworkingEngine: DeprecatedCustomAPIClient,
         authTicket: AuthTicket? = nil,
         logger: Logger,
         cryptoSettings: CryptoRawConfig?) throws {
        self.syncService = syncService
        self.sessionCryptoUpdater = sessionCryptoUpdater
        let activityReporter = AccountCryptoChangeActivityReporter(type: reportedType,
                                                                   migratingSession: migratingSession,
                                                                   activityReporter: activityReporter)
        personalDataMigrationFinalizer = EncryptionMigrationFinalizer(migratingSession: migratingSession,
                                                                      mode: mode,
                                                                      sessionsContainer: sessionsContainer,
                                                                      syncService: syncService,
                                                                      sessionCryptoUpdater: sessionCryptoUpdater,
                                                                      postCryptoChangeHandler: postCryptoChangeHandler,
                                                                      activityReporter: activityReporter)

        let cryptoEngine = CryptoChangerEngine(current: migratingSession.source.remoteCryptoEngine,
                                               new: migratingSession.target.remoteCryptoEngine)

        let remoteKeys: [CoreSync.RemoteKey]? = try migratingSession.target.encryptedRemoteKey()
            .map { $0.base64EncodedString() }
            .map {
                [RemoteKey(uuid: UUID().uuidString.lowercased(),
                           key: $0,
                           type: migratingSession.target.configuration.info.isPartOfSSOCompany ? .sso : .masterPassword)]
            }

        personalDataEncryptionMigrater = EncryptionMigrater(mode: mode,
                                                            delegate: personalDataMigrationFinalizer,
                                                            decryptEngine: cryptoEngine,
                                                            encryptEngine: cryptoEngine,
                                                            database: MigrationCryptoDBStack(driver: databaseDriver),
                                                            signatureBasedNetworkingEngine: apiNetworkingEngine,
                                                            authTicket: authTicket,
                                                            remoteKeys: remoteKeys,
                                                            cryptoSettings: cryptoSettings,
                                                            logger: logger)
    }

    func start() {
        guard let syncService = syncService else {
            self.personalDataEncryptionMigrater.start()
            return
        }
        syncService.syncAndDisable { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.delegate?.didFinish(with: .failure(.syncFailed(error)))
            case .success:
                self.sessionCryptoUpdater?.disable()
                self.personalDataEncryptionMigrater.start()
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

    public init(migratingSession: MigratingSession,
                mode: MigrationUploadMode,
                sessionsContainer: SessionsContainerProtocol,
                syncService: SyncServiceProtocol?,
                sessionCryptoUpdater: SessionCryptoUpdater?,
                postCryptoChangeHandler: PostAccountCryptoChangeHandler,
                activityReporter: AccountCryptoChangeActivityReporter) {
        self.migratingSession = migratingSession
        self.mode = mode
        self.sessionsContainer = sessionsContainer
        self.syncService = syncService
        self.sessionCryptoUpdater = sessionCryptoUpdater
        self.postCryptoChangeHandler = postCryptoChangeHandler
        self.activityReporter = activityReporter
    }

    weak var delegate: AccountCryptoChangerServiceDelegate?

    func complete(with timestamp: Timestamp, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        DispatchQueue.global().async {
            let result = Result<Session, Error> {
                let session = try self.sessionsContainer.finalizeMigration(using: self.migratingSession)
                try self.postCryptoChangeHandler.handle(session, syncTimestamp: timestamp)
                return session
            }
            completionHandler(result)
        }
    }

    func didProgress(_ progression: EncryptionMigrater<EncryptionMigrationFinalizer>.Progression) {
        delegate?.didProgress(progression)
    }

    func didFinish(with result: AccountMigrationResult) {
                if result.isFailure || mode == .cryptoConfigChange {
            self.syncService?.enableSync(triggeredBy: .settingsChange)
            self.sessionCryptoUpdater?.enable()
        }
        activityReporter.report(result)
        delegate?.didFinish(with: result.mapError { .encryptionError($0) })
    }
}

typealias AccountMigraterError = EncryptionMigrater<EncryptionMigrationFinalizer>.MigraterError
typealias AccountMigrationResult = Result<Session, AccountMigraterError>
