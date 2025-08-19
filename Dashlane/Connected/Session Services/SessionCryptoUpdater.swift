import Combine
import CoreCrypto
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSync
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation
import VaultKit

class SessionCryptoUpdater {
  let session: Session
  let sessionsContainer: SessionsContainerProtocol
  let syncService: SyncServiceProtocol
  let databaseDriver: DatabaseDriver
  let apiClient: UserDeviceAPIClient
  let userSpacesService: UserSpacesService
  let featureService: FeatureServiceProtocol
  let activityReporter: ActivityReporterProtocol
  let userDeviceApiClient: UserDeviceAPIClient
  let settings: SyncedSettingsService
  let logger: Logger
  private var subscription: AnyCancellable?
  @Atomic
  private var activeAccountCryptoChanger: AccountCryptoChangerService?

  @Atomic
  private var isDisabled = false

  var subscriptions = Set<AnyCancellable>()

  init(
    session: Session,
    sessionsContainer: SessionsContainerProtocol,
    syncService: SyncServiceProtocol,
    databaseDriver: DatabaseDriver,
    activityReporter: ActivityReporterProtocol,
    apiClient: UserDeviceAPIClient,
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    settings: SyncedSettingsService,
    logger: Logger,
    userDeviceApiClient: UserDeviceAPIClient
  ) {
    self.session = session
    self.sessionsContainer = sessionsContainer
    self.syncService = syncService
    self.databaseDriver = databaseDriver
    self.activityReporter = activityReporter
    self.apiClient = apiClient
    self.userSpacesService = userSpacesService
    self.featureService = featureService
    self.settings = settings
    self.logger = logger
    self.userDeviceApiClient = userDeviceApiClient
    let teamspaceCryptoPublisher = userSpacesService
      .$configuration
      .map {
        $0.currentTeam?.teamInfo.cryptoForcedPayload
      }
      .debounce(for: .seconds(1), scheduler: RunLoop.main)

    subscription = settings
      .didChange
      .prepend(Void())
      .combineLatest(teamspaceCryptoPublisher)
      .sink { [weak self] _, businessTeam in
        self?.update(withTeamCryptoPayload: businessTeam)
      }

  }

  func disable() {
    isDisabled = true
  }

  func enable() {
    isDisabled = false
  }

  private func update(withTeamCryptoPayload teamCryptoPayload: String?) {
    guard activeAccountCryptoChanger == nil, !isDisabled else {
      return
    }

    var cryptoRawConfigForUser = settings[\.cryptoConfig] ?? session.cryptoEngine.config
    let currentCryptoConfig = try? CryptoConfiguration(
      rawConfigMarker: cryptoRawConfigForUser.marker)

    let isLegacy = currentCryptoConfig == .legacy(.kwc3)

    if cryptoRawConfigForUser.fixedSalt == nil,
      currentCryptoConfig?.saltLength != nil
    {
      cryptoRawConfigForUser.fixedSalt = try? currentCryptoConfig?.makeDerivationSalt()
    }

    let isSSO = session.configuration.info.accountType == .sso
    let config: CryptoRawConfig
    if isSSO {
      config = CryptoRawConfig.noDerivationDefault
    } else {
      config = CryptoRawConfig(
        fixedSalt: cryptoRawConfigForUser.fixedSalt,
        userMarker: cryptoRawConfigForUser.marker,
        teamSpaceMarker: teamCryptoPayload)
    }

    if !isSSO
      && teamCryptoPayload == nil
      && isLegacy
    {

      migrateSession(to: .masterPasswordBasedDefault, cryptoRawConfigForUser: config)
    } else if session.cryptoEngine.config != config {
      updateOnlyLocalSessionData(to: config, cryptoRawConfigForUser: cryptoRawConfigForUser)
    }
  }

  private func migrateSession(to config: CryptoRawConfig, cryptoRawConfigForUser: CryptoRawConfig) {
    do {

      let migratingSession = try sessionsContainer.prepareMigration(
        of: session, to: session.configuration, cryptoConfig: config)

      let postCryptoChangeHandler = PostCryptoSettingsChangeHandler(syncService: syncService)
      let activeAccountCryptoChanger = try AccountCryptoChangerService(
        mode: .cryptoConfigChange,
        reportedType: .migrateLegacy,
        migratingSession: migratingSession,
        syncService: syncService,
        activityReporter: activityReporter,
        sessionsContainer: sessionsContainer,
        databaseDriver: databaseDriver,
        postCryptoChangeHandler: postCryptoChangeHandler,
        apiClient: apiClient,
        logger: self.logger,
        cryptoSettings: config)
      activeAccountCryptoChanger.progressPublisher.sink { [weak self] state in
        guard let self = self else {
          return
        }
        switch state {
        case let .inProgress(progression):
          self.didProgress(progression)
        case .completed:
          self.didComplete()
        case .failed(let error):
          self.didFail(with: error)
        }
      }.store(in: &subscriptions)
      activeAccountCryptoChanger.start()
      self.activeAccountCryptoChanger = activeAccountCryptoChanger

    } catch {
      self.logger.fatal("Session Crypto Migration has failed", error: error)
    }
  }

  private func updateOnlyLocalSessionData(
    to config: CryptoRawConfig, cryptoRawConfigForUser: CryptoRawConfig
  ) {
    let reportedType: Definition.CryptoMigrationType =
      config.marker != cryptoRawConfigForUser.marker ? .teamEnforced : .settingsApplyLocally

    let reporter = AccountCryptoChangeActivityReporter(
      type: reportedType,
      previousConfig: session.cryptoEngine.config,
      newConfig: config,
      activityReporter: activityReporter)
    do {
      try sessionsContainer.update(config, for: session)
      self.logger.info("Session Crypto updated with \(config.marker)")

      self.settings[\.cryptoConfig] = cryptoRawConfigForUser

      reporter.report(.success)
    } catch {
      self.logger.error("Update Session crypto failed", error: error)
      reporter.report(.errorUpdateLocalData)
    }
  }
}

extension SessionCryptoUpdater {
  func didProgress(_ progression: AccountCryptoChangerService.Progression) {
    logger.debug("Migration progress: \(progression)")
  }

  func didComplete() {
    self.activeAccountCryptoChanger = nil
    logger.info("Session Crypto Migration is successful")
  }

  func didFail(with error: Error) {
    self.activeAccountCryptoChanger = nil
    logger.fatal("Session Crypto Migration has failed", error: error)
  }
}

extension SessionCryptoUpdater {

  static var mock: SessionCryptoUpdater {
    SessionCryptoUpdater(
      session: .mock,
      sessionsContainer: .mock,
      syncService: .mock(),
      databaseDriver: InMemoryDatabaseDriver(),
      activityReporter: .mock,
      apiClient: .fake,
      userSpacesService: .mock(),
      featureService: .mock(),
      settings: .mock,
      logger: .mock,
      userDeviceApiClient: .fake)
  }
}
