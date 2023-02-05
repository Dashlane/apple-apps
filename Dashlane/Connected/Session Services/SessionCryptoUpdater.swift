import Foundation
import CoreSession
import CoreSync
import DashTypes
import Combine
import DashlaneCrypto
import SwiftTreats
import CoreUserTracking
import DashlaneAppKit
import CorePremium
import CorePersonalData
import CoreNetworking
import CoreFeature

class SessionCryptoUpdater {
    let session: Session
    let sessionsContainer: SessionsContainerProtocol
    let syncService: SyncServiceProtocol
    let databaseDriver: DatabaseDriver
    let networkEngine: DeprecatedCustomAPIClient
    let teamSpacesService: TeamSpacesService
    let featureService: FeatureServiceProtocol
    let activityReporter: ActivityReporterProtocol

    let settings: SyncedSettingsService
    let logger: Logger
    private var subscription: AnyCancellable?
    @Atomic
    private var activeAccountCryptoChanger: AccountCryptoChangerService?

    @Atomic
    private var isDisabled = false

    init(session: Session,
         sessionsContainer: SessionsContainerProtocol,
         syncService: SyncServiceProtocol,
         databaseDriver: DatabaseDriver,
         activityReporter: ActivityReporterProtocol,
         networkEngine: DeprecatedCustomAPIClient,
         teamSpacesService: TeamSpacesService,
         featureService: FeatureServiceProtocol,
         settings: SyncedSettingsService,
         logger: Logger) {
        self.session = session
        self.sessionsContainer = sessionsContainer
        self.syncService = syncService
        self.databaseDriver = databaseDriver
        self.activityReporter = activityReporter
        self.networkEngine = networkEngine
        self.teamSpacesService = teamSpacesService
        self.featureService = featureService
        self.settings = settings
        self.logger = logger

        let teamspaceCryptoPublisher = teamSpacesService
            .$businessTeamsInfo
            .map {
                $0.availableBusinessTeam
        }.removeDuplicates()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)

        subscription = settings
            .didChange
            .prepend(Void())
            .combineLatest(teamspaceCryptoPublisher)
            .sink {  [weak self]  _, businessTeam in
                self?.update(with: businessTeam)
        }

    }

    func disable() {
        isDisabled = true
    }

    func enable() {
        isDisabled = false
    }

    private func update(with team: BusinessTeam?) {
        guard activeAccountCryptoChanger == nil, !isDisabled else {
            return
        }

        var cryptoRawConfigForUser = settings[\.cryptoConfig] ?? session.cryptoEngine.config 
        let cryptoCenterForUser = CryptoCenter(from: cryptoRawConfigForUser.parametersHeader)
        let isLegacy = cryptoCenterForUser?.config == .kwc3

                if cryptoRawConfigForUser.fixedSalt == nil,
            let cryptoCenter = cryptoCenterForUser,
            cryptoCenter.config.saltLength > 0 {
            cryptoRawConfigForUser.fixedSalt = Random.randomData(ofSize: cryptoCenter.config.saltLength)
        }

                let teamspaceCrypto = !teamSpacesService.isSSOUser ? team?.space.info.cryptoForcedPayload : nil
        let config = !teamSpacesService.isSSOUser ? CryptoRawConfig(fixedSalt: cryptoRawConfigForUser.fixedSalt,
                                                                    userParametersHeader: cryptoRawConfigForUser.parametersHeader,
                                                                    teamSpaceParametersHeader: teamspaceCrypto) : CryptoRawConfig.keyBasedDefault

                if !teamSpacesService.isSSOUser
            && teamspaceCrypto == nil
            && isLegacy {

            migrateSession(to: .masterPasswordBasedDefault, cryptoRawConfigForUser: config)
        }
                        else if session.cryptoEngine.config != config {
            updateOnlyLocalSessionData(to: config, cryptoRawConfigForUser: cryptoRawConfigForUser)
        }
    }

    private func migrateSession(to config: CryptoRawConfig, cryptoRawConfigForUser: CryptoRawConfig) {
        do {

            let migratingSession = try sessionsContainer.prepareMigration(of: session, to: session.configuration, cryptoConfig: config)

            let postCryptoChangeHandler = PostCryptoSettingsChangeHandler(syncService: syncService)
            let activeAccountCryptoChanger = try AccountCryptoChangerService(mode: .cryptoConfigChange,
                                                                             reportedType: .migrateLegacy,
                                                                             migratingSession: migratingSession,
                                                                             syncService: syncService,
                                                                             activityReporter: activityReporter,
                                                                             sessionsContainer: sessionsContainer,
                                                                             databaseDriver: databaseDriver,
                                                                             postCryptoChangeHandler: postCryptoChangeHandler,
                                                                             apiNetworkingEngine: networkEngine,
                                                                             logger: self.logger,
                                                                             cryptoSettings: config)
            activeAccountCryptoChanger.delegate = self
            activeAccountCryptoChanger.start()
            self.activeAccountCryptoChanger = activeAccountCryptoChanger

        } catch {
            self.logger.fatal("Session Crypto Migration has failed", error: error)
        }
    }

    private func updateOnlyLocalSessionData(to config: CryptoRawConfig, cryptoRawConfigForUser: CryptoRawConfig) {
        let reportedType: Definition.CryptoMigrationType = config.parametersHeader != cryptoRawConfigForUser.parametersHeader ? .teamEnforced : .settingsApplyLocally

        let reporter = AccountCryptoChangeActivityReporter(type: reportedType,
                                                           previousConfig: session.cryptoEngine.config,
                                                           newConfig: config,
                                                           activityReporter: activityReporter)
        do {
            try sessionsContainer.update(config, for: session)
            self.logger.info("Session Crypto updated with \(config.parametersHeader)")

                                    self.settings[\.cryptoConfig] = cryptoRawConfigForUser

            reporter.report(.success)
        } catch {
            self.logger.error("Update Session crypto failed", error: error)
            reporter.report(.errorUpdateLocalData)
        }
    }
}

extension SessionCryptoUpdater: AccountCryptoChangerServiceDelegate {
    func didProgress(_ progression: AccountCryptoChangerService.Progression) {
        logger.debug("Migration progress: \(progression)")
    }

    func didFinish(with result: Result<Session, AccountCryptoChangerError>) {
        self.activeAccountCryptoChanger = nil
        switch result {
        case .success:
            logger.info("Session Crypto Migration is successful")
        case let .failure(error):
            logger.fatal("Session Crypto Migration has failed", error: error)
        }
    }
 }

extension SessionCryptoUpdater {

    static var mock: SessionCryptoUpdater {
        SessionCryptoUpdater(session: .mock,
                             sessionsContainer: SessionsContainer<InMemorySessionStoreProvider>.mock,
                             syncService: SyncServiceMock(),
                             databaseDriver: InMemoryDatabaseDriver(),
                             activityReporter: .fake,
                             networkEngine: .fake,
                             teamSpacesService: .mock(),
                             featureService: .mock(),
                             settings: .mock,
                             logger: LoggerMock())
    }
}
