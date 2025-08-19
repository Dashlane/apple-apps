import AutofillKit
import Combine
import CoreCategorizer
import CoreCrypto
import CoreFeature
import CoreNetworking
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreSharing
import CoreSync
import CoreTeamAuditLogs
import CoreTypes
import CoreUserTracking
import DashlaneAPI
import DomainParser
import Foundation
import IconLibrary
import Logger
import LoginKit
import SwiftTreats
import UIKit
import UserTrackingFoundation
import VaultKit

struct SessionServicesContainer: DependenciesContainer {

  let session: Session
  let database: ApplicationDatabase
  let syncService: SyncService
  let settings: LocalSettingsStore
  let syncedSettings: SyncedSettingsService

  let userSettings: UserSettings
  let domainIconLibrary: DomainIconLibrary
  let appServices: AppServicesContainer
  let autofillService: AutofillStateServiceProtocol
  let featureService: FeatureService
  let vaultStateService: VaultStateService
  let authenticatedABTestingService: AuthenticatedABTestingService
  let activityReporter: ActivityReporterProtocol
  let premiumStatusServicesSuit: PremiumStatusServicesSuit
  let teamAuditLogsService: TeamAuditLogsServiceProtocol
  let userDeviceAPIClient: UserDeviceAPIClient
  let encryptedAPIClient: UserSecureNitroEncryptionAPIClient
  let vaultItemsLimitService: VaultItemsLimitService
  let pasteboardService: PasteboardServiceProtocol
  let accessControlService: AccessControlService

  init(session: Session, appServices: AppServicesContainer, context: SessionLoadingContext)
    async throws
  {
    await appServices.crashReporterService.configureScope(for: session, loadingContext: context)

    appServices.rootLogger[.session].info("Loading services...")

    self.session = session
    self.appServices = appServices

    appServices.spiegelSettingsManager.cryptoEngine = session.localCryptoEngine
    appServices.remoteLogger.configureReportedDeviceId(
      session.configuration.keys.serverAuthentication.deviceId)

    self.settings = try await appServices.settingsManager.fetchOrCreateSettings(
      for: session.login, cryptoEngine: session.cryptoEngine)
    self.userSettings = settings.keyed(by: UserSettingsKey.self)

    let credentials = UserCredentials(configuration: session.configuration)
    self.userDeviceAPIClient = appServices.appAPIClient.makeUserClient(credentials: credentials)
    self.encryptedAPIClient = try appServices.appAPIClient.makeAppNitroEncryptionAPIClient()
      .makeSecureNitroEncryptionAPIClient(
        secureTunnelCreatorType: NitroSecureTunnelCreatorImpl.self,
        userCredentials: credentials)

    self.featureService = await FeatureService(
      session: session,
      apiClient: userDeviceAPIClient.features,
      apiAppClient: appServices.appAPIClient.features,
      logger: appServices.rootLogger[.features],
      useCacheOnly: true)
    self.activityReporter = await UserTrackingSessionActivityReporter(
      appReporter: appServices.userTrackingAppActivityReporter,
      login: session.login,
      analyticsIdentifiers: session.configuration.keys.analyticsIds
    )
    premiumStatusServicesSuit = try PremiumStatusServicesSuit(
      cache: SessionPremiumStatusCache(session: session))

    let databaseDriver = try SQLiteDriver(session: session, target: .current)
    let fakeSharingHandler = TachyonSharingHandler()
    let sharingKeysStore = await SharingKeysStore(
      session: session, logger: appServices.rootLogger[.sync])
    self.syncService = try await SyncService(
      apiClient: userDeviceAPIClient,
      sharingKeysStore: sharingKeysStore,
      databaseDriver: databaseDriver,
      sharingHandler: fakeSharingHandler,
      session: session,
      loadingContext: context,
      syncLogger: appServices.rootLogger[.sync],
      target: .current)

    self.database = await ApplicationDBStack(
      driver: databaseDriver,
      historyUserInfo: .init(session: session),
      codeDecoder: appServices.regionInformationService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      logger: appServices.rootLogger[.personalData])
    self.syncedSettings = try SyncedSettingsService(
      logger: appServices.rootLogger[.personalData],
      database: database
    )
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

    self.pasteboardService = PasteboardService(userSettings: userSettings)

    let secureLockProvider = SecureLockProvider(
      login: session.login,
      settings: settings,
      keychainService: appServices.keychainService)
    self.accessControlService = AccessControlService(
      session: session,
      secureLockModeProvider: secureLockProvider,
      userSettings: userSettings)

    autofillService = AutofillStateService(
      credentialsPublisher: credentialsPublisher,
      passkeysPublisher: passkeysPublisher,
      cryptoEngine: session.localCryptoEngine,
      vaultStateService: vaultStateService,
      logger: appServices.rootLogger[.autofill],
      snapshotFolderURL: try session.directory.storeURL(for: .galactica, in: .current))

    let cacheDirectory = try session.directory.storeURL(for: .icons, in: .current)
    domainIconLibrary = await DomainIconLibrary(
      cacheDirectory: cacheDirectory,
      inMemoryCacheSize: 100,
      cryptoEngine: session.localCryptoEngine,
      userDeviceAPIClient: userDeviceAPIClient,
      logger: appServices.rootLogger.sublogger(for: AppLoggerIdentifier.iconLibrary)
    )

    self.teamAuditLogsService = try TeamAuditLogsService(
      team: premiumStatusServicesSuit.statusProvider.status.b2bStatus?.currentTeam,
      featureService: featureService,
      logsAPIClient: encryptedAPIClient.logs,
      cryptoEngine: session.localCryptoEngine,
      session: session,
      target: .current,
      logger: appServices.rootLogger[.teamAuditLogs])
    self.authenticatedABTestingService = await AuthenticatedABTestingService(
      logger: appServices.rootLogger[.abTesting],
      userEmail: session.login.email,
      authenticatedAPIClient: userDeviceAPIClient,
      fetchingStrategy: .onlyCache,
      testsToEvaluate: AuthenticatedABTestingService.testsToEvaluate,
      cache: settings.keyed(by: UserSettingsKey.self))
    appServices.rootLogger[.session].info("Services ready")
  }
}

private final class TachyonSharingHandler: SharingSyncHandler {
  var manualSyncHandler: () -> Void = {}
  func sync(using sharingInfo: CoreSync.SharingSummaryInfo?) async {}
}

public final class TachyonSharingService: SharedVaultHandling {
  public func permission(for item: any VaultItem) -> CoreTypes.SharingPermission? { .none }
  public func deleteBehaviour(for item: VaultItem) async throws -> CoreSharing.ItemDeleteBehaviour {
    .normal
  }
  public func deleteBehaviour(for id: CoreTypes.Identifier) async throws
    -> CoreSharing.ItemDeleteBehaviour
  { .normal }
  public func refuseAndDelete(_ item: VaultItem) async throws {}
  public var manualSyncHandler: () -> Void = {}
  public func sync(using sharingInfo: CoreSync.SharingSummaryInfo?) async {}
}

extension VaultItemRow: SessionServicesInjecting {}
extension VaultItemIconViewModel: SessionServicesInjecting {}
extension AddCredentialViewModel: SessionServicesInjecting {}
extension PhishingWarningViewModel: SessionServicesInjecting {}
extension AccessControlRequestViewModifierModel: SessionServicesInjecting {}
extension AccessControlViewModel: SessionServicesInjecting {}
