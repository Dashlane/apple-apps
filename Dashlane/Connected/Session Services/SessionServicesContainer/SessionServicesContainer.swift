import AuthenticatorKit
import AutofillKit
import Combine
import CoreActivityLogs
import CoreCrypto
import CoreFeature
import CoreNetworking
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreSharing
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import DocumentServices
import Foundation
import Logger
import LoginKit
import NotificationKit
import SwiftTreats
import UIKit
import VaultKit
import ZXCVBN

struct SessionServicesContainer: DependenciesContainer {
  let loadingContext: SessionLoadingContext
  let session: Session
  let appServices: AppServicesContainer
  let iconService: IconServiceProtocol
  let spiegelLocalSettingsStore: LocalSettingsStore
  let spiegelUserSettings: UserSettings
  let spiegelUserEncryptedSettings: UserEncryptedSettings

  let userDeviceAPIClient: UserDeviceAPIClient
  let resetMasterPasswordService: ResetMasterPasswordService
  let dwmOnboardingSettings: DWMOnboardingSettings

  let databaseDriver: DatabaseDriver
  let database: ApplicationDatabase
  let syncService: SyncService
  let premiumStatusServicesSuit: PremiumStatusServicesSuit
  let appStoreServicesSuit: AppStoreServicesSuit
  let syncedSettings: SyncedSettingsService
  let sessionCryptoUpdater: SessionCryptoUpdater
  let vaultServicesSuit: VaultServicesSuit
  let autofillService: AutofillService
  let lockService: LockService
  let accessControlService: AccessControlService
  let documentStorageService: DocumentStorageService
  let identityDashboardService: IdentityDashboardService
  let todayExtensionCommunicator: AppTodayExtensionCommunicator
  let watchAppCommunicator: AppWatchAppCommunicator
  let notificationService: SessionNotificationService
  let vpnService: VPNService
  let authenticatedABTestingService: AuthenticatedABTestingService
  let featureService: FeatureService
  let vaultStateService: VaultStateService
  let sharingService: SharingService
  let onboardingService: OnboardingService
  let dwmOnboardingService: DWMOnboardingService
  let darkWebMonitoringService: DarkWebMonitoringService
  let toolsService: ToolsService
  let sessionReporterService: SessionReporterService
  let otpDatabaseService: OTPDatabaseService
  let activityLogsService: ActivityLogsServiceProtocol
  let pasteboardService: PasteboardServiceProtocol
  let teamRulesEnforcer: TeamRulesEnforcer

  var rootLogger: DashTypes.Logger {
    appServices.rootLogger
  }

  init(
    appServices: AppServicesContainer,
    session: Session,
    loadingContext: SessionLoadingContext
  ) async throws {
    await appServices.crashReporter.associate(to: session.login)
    appServices.remoteLogger.configureReportedDeviceId(
      session.configuration.keys.serverAuthentication.deviceId)
    self.loadingContext = loadingContext
    self.session = session
    self.appServices = appServices
    let logger = appServices.rootLogger
    logger[.session].info("Services loading begin")

    self.userDeviceAPIClient = appServices.appAPIClient.makeUserClient(
      sessionConfiguration: session.configuration)

    self.iconService = await IconService(
      session: session,
      userDeviceAPIClient: appServices.appAPIClient.makeUserClient(
        sessionConfiguration: session.configuration),
      logger: logger[.iconLibrary],
      target: .current
    )

    let activityReporter = UserTrackingSessionActivityReporter(
      appReporter: appServices.activityReporter,
      login: session.login,
      analyticsIdentifiers: session.configuration.keys.analyticsIds)
    self.spiegelLocalSettingsStore = try appServices.spiegelSettingsManager.fetchOrCreateSettings(
      for: session)
    self.spiegelUserSettings = spiegelLocalSettingsStore.keyed(by: UserSettingsKey.self)
    self.spiegelUserEncryptedSettings = spiegelLocalSettingsStore.keyed(
      by: UserEncryptedSettingsKey.self)
    dwmOnboardingSettings = spiegelLocalSettingsStore.keyed(by: DWMOnboardingSettingsKey.self)

    self.resetMasterPasswordService = ResetMasterPasswordService(
      login: session.login, settings: spiegelLocalSettingsStore,
      keychainService: appServices.keychainService)

    databaseDriver = try SQLiteDriver(session: session, target: .current)

    self.featureService = await FeatureService(
      session: session,
      apiClient: userDeviceAPIClient.features,
      apiAppClient: appServices.appAPIClient.features,
      logger: logger[.features])

    self.premiumStatusServicesSuit = try await PremiumStatusServicesSuit(
      client: userDeviceAPIClient,
      cache: SessionPremiumStatusCache(session: session),
      refreshTrigger: NotificationCenter.default.publisher(
        for: UIApplication.didBecomeActiveNotification
      ).map { _ in },
      logger: appServices.rootLogger[.session])

    self.appStoreServicesSuit = try await AppStoreServicesSuit(
      login: session.login,
      userDeviceAPIClient: userDeviceAPIClient,
      statusProvider: premiumStatusServicesSuit.statusProvider,
      receiptHashStore: spiegelUserEncryptedSettings,
      logger: appServices.rootLogger[.inAppPurchase])

    self.activityLogsService = ActivityLogsService(
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      featureService: featureService,
      apiClient: userDeviceAPIClient.teams.storeActivityLogs,
      cryptoEngine: session.localCryptoEngine,
      logger: appServices.rootLogger[.activityLogs])

    let sharingKeysStore = await SharingKeysStore(
      session: session, logger: appServices.rootLogger[.sync])

    self.database = ApplicationDBStack(
      driver: databaseDriver,
      historyUserInfo: .init(session: session),
      codeDecoder: appServices.regionInformationService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      logger: logger[.personalData])

    self.sharingService = try await SharingService(
      session: session,
      apiClient: userDeviceAPIClient.sharingUserdevice,
      codeDecoder: appServices.regionInformationService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      databaseDriver: databaseDriver,
      sharingKeysStore: sharingKeysStore,
      activityLogsService: activityLogsService,
      logger: logger[.sharing],
      activityReporter: activityReporter,
      autoRevokeUsersWithInvalidProposeSignature: featureService.isEnabled(
        .autoRevokeInvalidSharingSignatureEnabled),
      applicationDatabase: database,
      buildTarget: .app)

    self.syncService = try await SyncService(
      apiClient: userDeviceAPIClient,
      activityReporter: activityReporter,
      sharingKeysStore: sharingKeysStore,
      databaseDriver: databaseDriver,
      sharingHandler: sharingService,
      session: session,
      loadingContext: loadingContext,
      syncLogger: logger[.sync],
      target: .app
    )

    self.syncedSettings = try SyncedSettingsService(
      logger: logger[.personalData],
      database: database)

    self.authenticatedABTestingService = await AuthenticatedABTestingService(
      userSettings: spiegelUserSettings,
      logger: logger[.abTesting],
      login: session.login,
      loadingContext: loadingContext,
      authenticatedAPIClient: userDeviceAPIClient)

    self.notificationService = await SessionNotificationService(
      login: session.login,
      notificationService: appServices.notificationService,
      syncService: syncService,
      brazeService: appServices.brazeService,
      settings: spiegelUserSettings,
      userDeviceAPIClient: userDeviceAPIClient,
      logger: logger[.remoteNotifications])

    self.sessionCryptoUpdater = SessionCryptoUpdater(
      session: session,
      sessionsContainer: appServices.sessionContainer,
      syncService: syncService,
      databaseDriver: databaseDriver,
      activityReporter: activityReporter,
      apiClient: userDeviceAPIClient,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      featureService: featureService,
      settings: syncedSettings,
      logger: logger[.session],
      userDeviceApiClient: userDeviceAPIClient)

    self.vaultServicesSuit = await VaultServicesSuit(
      logger: logger[.personalData],
      login: session.login,
      context: loadingContext,
      spotlightIndexer: appServices.spotlightIndexer,
      userSettings: spiegelUserSettings,
      categorizer: appServices.categorizer,
      urlDecoder: appServices.personalDataURLDecoder,
      sharingHandling: sharingService,
      sharingService: sharingService,
      database: database,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      featureService: featureService,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      activityLogsService: activityLogsService,
      activityReporter: activityReporter
    )

    self.vaultStateService = VaultStateService(
      vaultItemsLimitService: vaultServicesSuit.vaultItemsLimitService,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      featureService: featureService)

    self.lockService = LockService(
      session: session,
      appSettings: appServices.globalSettings,
      settings: spiegelLocalSettingsStore,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      featureService: featureService,
      keychainService: appServices.keychainService,
      resetMasterPasswordService: resetMasterPasswordService,
      sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
      logger: logger[.session])

    self.accessControlService = AccessControlService(
      session: session,
      secureLockModeProvider: lockService.secureLockProvider)

    self.pasteboardService = PasteboardService(userSettings: spiegelUserSettings)

    self.documentStorageService = DocumentStorageService(
      database: database,
      userDeviceAPIClient: userDeviceAPIClient,
      cryptoProvider: CryptoConfiguration.file,
      lockedPublisher: lockService.locker.screenLockedPublisher,
      login: session.login)

    let passwordEvaluator =
      if featureService.isEnabled(.swiftZXCVBNIdentityDashboardEnabled) {
        ZXCVBN()
      } else {
        appServices.passwordEvaluator
      }
    self.identityDashboardService = IdentityDashboardService(
      session: session,
      settings: spiegelLocalSettingsStore,
      userDeviceAPIClient: userDeviceAPIClient,
      database: database,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      sharingKeysStore: sharingKeysStore,
      featureService: featureService,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      passwordEvaluator: passwordEvaluator,
      domainParser: appServices.domainParser,
      categorizer: appServices.categorizer,
      notificationService: notificationService,
      logger: logger[.identityDashboard])

    self.autofillService = AutofillService(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      cryptoEngine: session.localCryptoEngine,
      vaultStateService: vaultStateService,
      logger: logger[.autofill],
      snapshotFolderURL: try session.directory.storeURL(for: .galactica, in: .current)
    )

    self.todayExtensionCommunicator = AppTodayExtensionCommunicator(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      syncedSettings: syncedSettings,
      userSettings: spiegelUserSettings,
      anonymousDeviceId: appServices.globalSettings.anonymousDeviceId
    )

    self.watchAppCommunicator = AppWatchAppCommunicator(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore)

    self.darkWebMonitoringService = DarkWebMonitoringService(
      iconService: iconService,
      identityDashboardService: identityDashboardService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      deepLinkingService: appServices.deepLinkingService,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      activityReporter: activityReporter,
      userSettings: spiegelUserSettings
    )

    self.dwmOnboardingService = DWMOnboardingService(
      settings: dwmOnboardingSettings,
      identityDashboardService: identityDashboardService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      darkWebMonitoringService: darkWebMonitoringService,
      logger: logger[.dwmOnboarding]
    )

    self.onboardingService = OnboardingService(
      session: session,
      loadingContext: loadingContext,
      accountType: session.configuration.info.accountType,
      userSettings: spiegelUserSettings,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      dwmOnboardingSettings: dwmOnboardingSettings,
      dwmOnboardingService: dwmOnboardingService,
      syncedSettings: syncedSettings,
      abTestService: authenticatedABTestingService,
      lockService: lockService,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      featureService: featureService,
      autofillService: autofillService
    )

    let deviceInformationReporting = DeviceInformationReporting(
      userDeviceAPI: userDeviceAPIClient,
      logger: logger[.session],
      resetMasterPasswordService: resetMasterPasswordService,
      userSettings: spiegelUserSettings,
      lockService: lockService,
      autofillService: autofillService,
      session: session)

    self.vpnService = VPNService(
      capabilityService: premiumStatusServicesSuit.capabilityService,
      userDeviceAPIClient: userDeviceAPIClient,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      userSpacesService: premiumStatusServicesSuit.userSpacesService
    )

    let vaultReportService = VaultReportService(
      identityDashboardService: identityDashboardService,
      userSettings: spiegelUserSettings,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      apiClient: userDeviceAPIClient.useractivity,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      activityReporter: activityReporter)
    let reportService = ReportUserSettingsService(
      userSettings: spiegelUserSettings,
      resetMPService: resetMasterPasswordService,
      lock: lockService,
      autofillService: autofillService,
      activityReporter: activityReporter)
    self.sessionReporterService = SessionReporterService(
      activityReporter: activityReporter,
      deviceInformation: deviceInformationReporting,
      loginMetricsReporter: appServices.loginMetricsReporter,
      syncService: syncService,
      settings: spiegelLocalSettingsStore,
      vaultReportService: vaultReportService,
      reportUserSettingsService: reportService)

    self.otpDatabaseService = OTPDatabaseService(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      activityReporter: activityReporter,
      userSpacesService: premiumStatusServicesSuit.userSpacesService
    )

    teamRulesEnforcer = TeamRulesEnforcer(
      statusProvider: premiumStatusServicesSuit.statusProvider,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      database: database,
      sharingService: sharingService,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      apiClient: userDeviceAPIClient.teams,
      logger: logger[.session]
    )

    self.toolsService = ToolsService(
      featureService: featureService,
      capabilityService: premiumStatusServicesSuit.capabilityService)

    appServices.rootLogger[.session].info("Session Services loaded")
  }
  func postLoad() async {
    sessionReporterService.postLoadReport(for: loadingContext)
    sessionReporterService.configureReportOnSync()
    configureBraze()
    authenticatedABTestingService.reportClientControlledTests()
    appServices.crashReporter.enableSentry(featureService.isEnabled(.sentryIsEnabled))
    Task {
      if loadingContext.isAccountRecoveryLogin
        && session.configuration.info.accountType != .masterPassword
      {
        sessionReporterService.activityReporter.report(
          UserEvent.UseAccountRecoveryKey(flowStep: .complete))
        do {
          try await accountRecoveryKeyService.deactivateAccountRecoveryKey(for: .keyUsed)
        } catch {
          logger.fatal("Account Recovery Key auto disabling failed", error: error)
        }
      }

      if featureService.isEnabled(.postLaunchReceiptVerificationEnabled) {
        try await appStoreServicesSuit.receiptVerificationService.verifyReceiptPostLaunch()
      }
    }
  }

  private func configureBraze() {
    Task.detached(priority: .low) {
      await appServices.brazeService.registerLogin(
        session.login,
        using: spiegelUserSettings,
        userDeviceAPIClient: userDeviceAPIClient,
        featureService: featureService)
    }
  }
}

typealias ViewModelFactory = SessionServicesContainer

extension SessionServicesContainer {
  var viewModelFactory: ViewModelFactory {
    return self
  }

  var activityReporter: ActivityReporterProtocol {
    return sessionReporterService.activityReporter
  }
}

extension AddAttachmentButtonViewModel: SessionServicesInjecting {}
extension AttachmentRowViewModel: SessionServicesInjecting {}
extension AttachmentsListViewModel: SessionServicesInjecting {}
extension AttachmentsSectionViewModel: SessionServicesInjecting {}
extension PasswordGeneratorViewModel: SessionServicesInjecting {}
extension PremiumAnnouncementsViewModel: SessionServicesInjecting {}
extension LabsSettingsViewModel: SessionServicesInjecting {}
extension VaultItemIconViewModel: SessionServicesInjecting {}
extension VaultItemRow: SessionServicesInjecting {}
extension VaultCollectionEditionService: SessionServicesInjecting {}
