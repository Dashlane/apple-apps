import AuthenticatorKit
import Combine
import CoreActivityLogs
import CoreFeature
import CoreNetworking
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreSharing
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import IconLibrary
import Logger
import LoginKit
import SwiftTreats
import VaultKit

struct PairedServicesContainer: DependenciesContainer {
  let session: Session
  let authenticationMode: AuthenticationMode
  let appServices: AppServices
  let database: ApplicationDatabase
  let pairedDatabaseService: PairedDatabaseService
  let syncService: SyncServiceProtocol
  let sharingService: SharedVaultHandling
  let authenticatorService: SessionAuthenticatorService
  let domainIconLibrary: DomainIconLibraryProtocol
  let activityLogsService: ActivityLogsService
  let enabledFeatures: Set<ControlledFeature>
  let settings: LocalSettingsStore

  var databaseService: AuthenticatorDatabaseServiceProtocol { pairedDatabaseService }
  var sessionCredentialsProvider: SessionCredentialsProvider { pairedDatabaseService }

  init(
    session: Session,
    authenticationMode: AuthenticationMode,
    appServices: AppServices
  ) async throws {

    self.session = session
    self.authenticationMode = authenticationMode
    self.appServices = appServices

    let userAPIClient = appServices.appAPIClient.makeUserClient(
      sessionConfiguration: session.configuration
    )

    self.authenticatorService = SessionAuthenticatorService(
      apiClient: userAPIClient,
      notificationService: appServices.notificationService
    )

    let featureService = await FeatureService(
      session: session,
      apiClient: userAPIClient.features,
      apiAppClient: appServices.appAPIClient.features,
      logger: appServices.rootLogger[.features]
    )
    self.enabledFeatures = featureService.enabledFeatures()

    domainIconLibrary = await DomainIconLibrary(
      userDeviceAPIClient: userAPIClient,
      session: session,
      logger: appServices.rootLogger[.iconLibrary]
    )
    let databaseDriver = try SQLiteDriver(session: session, target: .current)
    settings = try appServices.spiegelSettingsManager.fetchOrCreateSettings(
      for: session.login,
      cryptoEngine: session.cryptoEngine
    )

    let sharingKeysStore = await SharingKeysStore(
      session: session,
      logger: appServices.rootLogger[.sync]
    )

    let premiumServices = try PremiumStatusServicesSuit(
      cache: SessionPremiumStatusCache(session: session))
    self.activityLogsService = ActivityLogsService(
      premiumStatusProvider: premiumServices.statusProvider,
      featureService: featureService,
      apiClient: userAPIClient.teams.storeActivityLogs,
      cryptoEngine: session.localCryptoEngine,
      logger: appServices.rootLogger[.activityLogs]
    )

    self.database = ApplicationDBStack(
      driver: databaseDriver,
      historyUserInfo: .init(
        session: session
      ),
      codeDecoder: appServices.regionInformationService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      logger: appServices.rootLogger[.personalData]
    )

    self.sharingService = try await SharingService(
      session: session,
      apiClient: userAPIClient.sharingUserdevice,
      codeDecoder: appServices.regionInformationService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      databaseDriver: databaseDriver,
      sharingKeysStore: sharingKeysStore,
      activityLogsService: activityLogsService,
      logger: appServices.rootLogger[.sharing],
      activityReporter: appServices.activityReporter,
      autoRevokeUsersWithInvalidProposeSignature: false,
      applicationDatabase: database,
      buildTarget: .current
    )

    self.syncService = try await SyncService(
      apiClient: userAPIClient,
      activityReporter: appServices.activityReporter,
      sharingKeysStore: sharingKeysStore,
      databaseDriver: databaseDriver,
      sharingHandler: sharingService,
      session: session,
      loadingContext: .localLogin(),
      syncLogger: appServices.rootLogger[.sync],
      target: .current
    )

    appServices.crashReporterService.associate(to: session.login)

    pairedDatabaseService = PairedDatabaseService(
      login: session.login.email,
      appDatabase: database,
      databaseService: AuthenticatorDatabaseService(
        logger: appServices.rootLogger[.localCommunication]
      ),
      sharingService: sharingService,
      activityLogsService: activityLogsService,
      userSpacesService: premiumServices.userSpacesService
    )
  }
}
