import AutofillKit
import Combine
import CoreActivityLogs
import CoreCategorizer
import CoreFeature
import CoreNetworking
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import DomainParser
import Foundation
import IconLibrary
import Logger
import LoginKit
import SwiftTreats
import UIKit
import VaultKit

final class SessionServicesContainer: DependenciesContainer {

  let session: Session
  let database: ApplicationDatabase
  let syncService: SyncService
  let settings: LocalSettingsStore
  let syncedSettings: SyncedSettingsService

  let userSettings: UserSettings
  let domainIconLibrary: DomainIconLibrary
  let appServices: AppServicesContainer
  let autofillService: AutofillService
  let featureService: FeatureService
  let vaultStateService: VaultStateService
  let authenticatedABTestingService: AuthenticatedABTestingService
  let activityReporter: ActivityReporterProtocol
  let premiumStatusServicesSuit: PremiumStatusServicesSuit
  let activityLogsService: ActivityLogsServiceProtocol
  let userDeviceAPIClient: UserDeviceAPIClient
  let vaultItemsLimitService: VaultItemsLimitService

  private init(
    session: Session,
    appServices: AppServicesContainer,
    activityReporter: UserTrackingSessionActivityReporter,
    database: ApplicationDatabase,
    syncService: SyncService,
    featureService: FeatureService,
    authenticatedABTestingService: AuthenticatedABTestingService
  ) async throws {
    await AppServicesContainer.crashReporterService.associate(to: session.login)
    appServices.remoteLogger.configureReportedDeviceId(
      session.configuration.keys.serverAuthentication.deviceId)
    self.session = session
    self.featureService = featureService
    self.syncService = syncService
    self.database = database
    self.appServices = appServices
    self.syncedSettings = try SyncedSettingsService(
      logger: appServices.rootLogger[.personalData],
      database: database
    )

    self.authenticatedABTestingService = authenticatedABTestingService
    appServices.settingsManager.cryptoEngine = session.localCryptoEngine
    self.activityReporter = activityReporter
    self.settings = try appServices.settingsManager.fetchOrCreateSettings(
      for: session.login, cryptoEngine: session.cryptoEngine)
    self.userSettings = settings.keyed(by: UserSettingsKey.self)

    let cacheDirectory = try session.directory.storeURL(for: .icons, in: .current)
    domainIconLibrary = await DomainIconLibrary(
      cacheDirectory: cacheDirectory,
      inMemoryCacheSize: 100,
      cryptoEngine: session.localCryptoEngine,
      userDeviceAPIClient: appServices.appAPIClient.makeUserClient(
        sessionConfiguration: session.configuration),
      logger: appServices.rootLogger.sublogger(for: AppLoggerIdentifier.iconLibrary)
    )
    premiumStatusServicesSuit = try PremiumStatusServicesSuit(
      cache: SessionPremiumStatusCache(session: session))

    let credentialsPublisher = database.itemsPublisher(for: Credential.self)
      .filter(by: premiumStatusServicesSuit.userSpacesService.$configuration)
    let passkeysPublisher = database.itemsPublisher(for: Passkey.self)
      .filter(by: premiumStatusServicesSuit.userSpacesService.$configuration)

    vaultItemsLimitService = VaultItemsLimitService(
      capabilityService: premiumStatusServicesSuit.capabilityService,
      credentialsPublisher: credentialsPublisher)

    vaultStateService = VaultStateService(
      vaultItemsLimitService: vaultItemsLimitService,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      featureService: featureService)

    autofillService = AutofillService(
      channel: .fromTachyon,
      credentialsPublisher: credentialsPublisher,
      passkeysPublisher: passkeysPublisher,
      cryptoEngine: session.localCryptoEngine,
      vaultStateService: vaultStateService,
      logger: appServices.rootLogger[.autofill],
      snapshotFolderURL: try session.directory.storeURL(for: .galactica, in: .current))

    self.userDeviceAPIClient = appServices.appAPIClient.makeUserClient(
      sessionConfiguration: session.configuration)
    self.activityLogsService = ActivityLogsService(
      team: premiumStatusServicesSuit.statusProvider.status.b2bStatus?.currentTeam,
      featureService: featureService,
      apiClient: userDeviceAPIClient.teams.storeActivityLogs,
      cryptoEngine: session.localCryptoEngine,
      logger: appServices.rootLogger[.activityLogs])
    appServices.rootLogger[.session].info("Services ready")
  }

  public static func load(for session: Session, appServices: AppServicesContainer) async throws
    -> SessionServicesContainer
  {
    appServices.rootLogger[.session].info("Loading services...")

    let userDeviceAPIClient = appServices.appAPIClient.makeUserClient(
      sessionConfiguration: session.configuration)

    let featureService = await FeatureService(
      session: session,
      apiClient: userDeviceAPIClient.features,
      apiAppClient: appServices.appAPIClient.features,
      logger: appServices.rootLogger[.features],
      useCacheOnly: true)

    let activityReporter = UserTrackingSessionActivityReporter(
      appReporter: appServices.activityReporter,
      login: session.login,
      analyticsIdentifiers: session.configuration.keys.analyticsIds
    )

    let databaseDriver = try SQLiteDriver(session: session, target: .current)

    let fakeSharingHandler = TachyonSharingHandler()
    let sharingKeysStore = await SharingKeysStore(
      session: session, logger: appServices.rootLogger[.sync])

    let syncService = try await SyncService(
      apiClient: userDeviceAPIClient,
      activityReporter: activityReporter,
      sharingKeysStore: sharingKeysStore,
      databaseDriver: databaseDriver,
      sharingHandler: fakeSharingHandler,
      session: session,
      loadingContext: .localLogin(),
      syncLogger: appServices.rootLogger[.sync],
      target: .current)
    let applicationDatabase = await ApplicationDBStack(
      driver: databaseDriver,
      historyUserInfo: .init(session: session),
      codeDecoder: appServices.regionInformationService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      logger: appServices.rootLogger[.personalData])

    let anonymousUserId = try applicationDatabase.fetch(with: Settings.id, type: Settings.self)?
      .anonymousUserId
    assert(anonymousUserId != nil)

    let settings = try appServices.settingsManager.fetchOrCreateSettings(
      for: session.login, cryptoEngine: session.cryptoEngine)

    let abTestingService = await AuthenticatedABTestingService(
      logger: appServices.rootLogger[.abTesting],
      userEmail: session.login.email,
      authenticatedAPIClient: userDeviceAPIClient,
      fetchingStrategy: .onlyCache,
      testsToEvaluate: AuthenticatedABTestingService.testsToEvaluate,
      cache: settings.keyed(by: UserSettingsKey.self))

    let container = try await SessionServicesContainer(
      session: session,
      appServices: appServices,
      activityReporter: activityReporter,
      database: applicationDatabase,
      syncService: syncService,
      featureService: featureService,
      authenticatedABTestingService: abTestingService
    )

    return container
  }
}

private final class TachyonSharingHandler: SharingSyncHandler {
  var manualSyncHandler: () -> Void = {}
  func sync(using sharingInfo: CoreSync.SharingSummaryInfo?) async {}
}

extension VaultItemRow: SessionServicesInjecting {}
extension VaultItemIconViewModel: SessionServicesInjecting {}
extension AddCredentialViewModel: SessionServicesInjecting {}
extension PhishingWarningViewModel: SessionServicesInjecting {}
