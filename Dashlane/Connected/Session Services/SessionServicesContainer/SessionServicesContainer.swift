import DashTypes
import Foundation
import Combine
import CoreSession
import CoreNetworking
import CorePersonalData
import CorePremium
import CoreFeature
import CoreSettings
import Logger
import DashlaneAppKit
import SwiftTreats
import DocumentServices
import LoginKit
import VaultKit
import CoreSync
import CoreSharing
import NotificationKit
import CoreUserTracking
import DashlaneAPI

struct SessionServicesContainer: DependenciesContainer {

    let loadingContext: SessionLoadingContext
    let session: Session
    let appServices: AppServicesContainer
    let iconService: IconService
    let spiegelLocalSettingsStore: LocalSettingsStore
    let spiegelUserSettings: UserSettings
    let spiegelUserEncryptedSettings: UserEncryptedSettings
    let subscriptionCodeFetcher: SubscriptionCodeFetcherService

    let legacyWebService: LegacyWebService
    let userDeviceAPIClient: UserDeviceAPIClient
    let resetMasterPasswordService: ResetMasterPasswordService
    let dwmOnboardingSettings: DWMOnboardingSettings

    let databaseDriver: DatabaseDriver
    let database: ApplicationDatabase
    let syncService: SyncService
    let premiumService: PremiumService
    let syncedSettings: SyncedSettingsService
    let teamSpacesService: TeamSpacesService
    let sessionCryptoUpdater: SessionCryptoUpdater
    let vaultItemsService: VaultItemsService
    let autofillService: AutofillService
    let lockService: LockService
    let accessControl: AccessControl
    let documentStorageService: DocumentStorageService
    let identityDashboardService: IdentityDashboardService
    let todayExtensionCommunicator: AppTodayExtensionCommunicator
    let watchAppCommunicator: AppWatchAppCommunicator
    let notificationService: SessionNotificationService
    let vpnService: VPNService
    let authenticatedABTestingService: AuthenticatedABTestingService
    let featureService: FeatureService
    let sharingService: SharingService
    let onboardingService: OnboardingService
    let dwmOnboardingService: DWMOnboardingService
    let darkWebMonitoringService: DarkWebMonitoringService
    let capabilityService: CapabilityServiceProtocol
    let authenticatorAppCommunicator: AuthenticatorService
    let toolsService: ToolsService
    let sharingLinkService: SharingLinkService
    let activityReporter: SessionReporterService

        private var subscriptions = Set<AnyCancellable>()

    var rootLogger: DashTypes.Logger {
        appServices.rootLogger
    }

        init(appServices: AppServicesContainer,
         session: Session,
         loadingContext: SessionLoadingContext) async throws {
        appServices.crashReporter.associate(to: session.login)
        appServices.remoteLogger.configureReportedDeviceId(session.configuration.keys.serverAuthentication.deviceId)
        self.loadingContext = loadingContext
        self.session = session
        self.appServices = appServices
        let keys = session.configuration.keys
        let logger = appServices.rootLogger
        logger[.session].info("Services loading begin")

        let ukiBasedWebService = LegacyWebServiceImpl(logger: appServices.rootLogger.sublogger(for: AppLoggerIdentifier.network))
        ukiBasedWebService.configureAuthentication(usingLogin: session.login.email, uki: keys.serverAuthentication.uki.rawValue)
        self.legacyWebService = ukiBasedWebService
        self.userDeviceAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)

        self.iconService = IconService(session: session,
                                       webservice: ukiBasedWebService,
                                       logger: logger[.iconLibrary],
                                       target: .current)
        
        let activityReporter = UserTrackingSessionActivityReporter(appReporter: appServices.activityReporter,
                                                                   login: session.login,
                                                                   analyticsIdentifiers: session.configuration.keys.analyticsIds)
        self.spiegelLocalSettingsStore = try appServices.spiegelSettingsManager.fetchOrCreateSettings(for: session)
        self.spiegelUserSettings = spiegelLocalSettingsStore.keyed(by: UserSettingsKey.self)
        self.spiegelUserEncryptedSettings = spiegelLocalSettingsStore.keyed(by: UserEncryptedSettingsKey.self)
        dwmOnboardingSettings = spiegelLocalSettingsStore.keyed(by: DWMOnboardingSettingsKey.self)

        self.resetMasterPasswordService = ResetMasterPasswordService(login: session.login, settings: spiegelLocalSettingsStore, keychainService: appServices.keychainService)

        self.subscriptionCodeFetcher = SubscriptionCodeFetcherService(session: session, engine: ukiBasedWebService)
        
        databaseDriver = try SQLiteDriver(session: session, target: .current)
        
        
        self.featureService = await FeatureService(session: session,
                                                   apiClient: userDeviceAPIClient.features,
                                                   logger: logger[.features])
        
        let sharingKeysStore = await SharingKeysStore(session: session, logger: appServices.rootLogger[.sync])

        self.sharingService = try await SharingService(session: session,
                                                       apiClient: userDeviceAPIClient.sharingUserdevice,
                                                       codeDecoder: appServices.regionInformationService,
                                                       personalDataURLDecoder: appServices.personalDataURLDecoder,
                                                       databaseDriver: databaseDriver,
                                                       sharingKeysStore: sharingKeysStore,
                                                       logger: logger[.sharing],
                                                       activityReporter: activityReporter)

        self.syncService = try await SyncService(apiClient: userDeviceAPIClient,
                                                 activityReporter: activityReporter,
                                                 sharingKeysStore: sharingKeysStore,
                                                 databaseDriver: databaseDriver,
                                                 sharingHandler: sharingService,
                                                 session: session,
                                                 syncLogger: logger[.sync],
                                                 target: .app)
        
        self.database = ApplicationDBStack(driver: databaseDriver,
                                           historyUserInfo: .init(session: session),
                                           codeDecoder: appServices.regionInformationService,
                                           personalDataURLDecoder: appServices.personalDataURLDecoder,
                                           logger: logger[.personalData])
    
        self.syncedSettings = try SyncedSettingsService(logger: logger[.personalData],
                                                        database: database)

        let usageLogService = UsageLogService(logDirectory: try session.directory.storeURL(for: .usageLogs, in: .current),
                                              cryptoService: session.localCryptoEngine,
                                              nonAuthenticatedLegacyWebService: appServices.nonAuthenticatedUKIBasedWebService,
                                              apiClient: appServices.appAPIClient,
                                              syncedSettings: syncedSettings,
                                              loginUsageLogService: appServices.loginUsageLogService,
                                              userSettings: spiegelUserSettings,
                                              anonymousDeviceId: appServices.globalSettings.anonymousDeviceId,
                                              login: session.login,
                                              logger: logger[.usageLogs])
        
        self.authenticatedABTestingService = await AuthenticatedABTestingService(userSettings: spiegelUserSettings,
                                                                                 logger: logger[.abTesting],
                                                                                 login: session.login,
                                                                                 loadingContext: loadingContext,
                                                                                 authenticatedAPIClient: userDeviceAPIClient,
                                                                                 usageLogService: usageLogService)
        
        self.premiumService = try await PremiumService(session: session,
                                                       userEncryptedSettings: spiegelUserEncryptedSettings,
                                                       legacyWebService: ukiBasedWebService,
                                                       apiClient: userDeviceAPIClient,
                                                       logger: logger[.session],
                                                       usageLogService: usageLogService)

        self.notificationService = await SessionNotificationService(login: session.login,
                                                                    notificationService: appServices.notificationService,
                                                                    usageLogService: usageLogService,
                                                                    syncService: syncService,
                                                                    brazeService: appServices.brazeService,
                                                                    settings: spiegelUserSettings,
                                                                    webService: legacyWebService,
                                                                    logger: logger[.remoteNotifications])
        
        self.teamSpacesService = TeamSpacesService(database: database,
                                                   usageLogService: usageLogService,
                                                   premiumService: premiumService,
                                                   syncedSettings: syncedSettings,
                                                   networkEngine: legacyWebService,
                                                   sharingService: sharingService,
                                                   logger: logger[.teamSpaces])
        
        self.sessionCryptoUpdater = SessionCryptoUpdater(session: session,
                                                         sessionsContainer: appServices.sessionContainer,
                                                         syncService: syncService,
                                                         databaseDriver: databaseDriver,
                                                         activityReporter: activityReporter,
                                                         networkEngine: userDeviceAPIClient,
                                                         teamSpacesService: teamSpacesService,
                                                         featureService: featureService,
                                                         settings: syncedSettings,
                                                         logger: logger[.session])

        self.vaultItemsService = await VaultItemsService(logger: logger[.personalData],
                                                         login: session.login,
                                                         context: loadingContext,
                                                         spotlightIndexer: appServices.spotlightIndexer,
                                                         userSettings: spiegelUserSettings,
                                                         categorizer: appServices.categorizer,
                                                         urlDecoder: appServices.personalDataURLDecoder,
                                                         sharingService: sharingService,
                                                         database: database,
                                                         teamSpacesService: teamSpacesService,
                                                         featureService: featureService)

        self.lockService = LockService(session: session,
                                       appSettings: appServices.globalSettings,
                                       settings: spiegelLocalSettingsStore,
                                       teamSpaceService: teamSpacesService,
                                       featureService: featureService,
                                       keychainService: appServices.keychainService,
                                       resetMasterPasswordService: resetMasterPasswordService,
                                       sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                                       logger: logger[.session])

        self.accessControl = AccessControl(session: session,
                                           teamSpaceService: teamSpacesService,
                                           secureLockProvider: lockService.secureLockProvider,
                                           activityReporter: activityReporter)
        
        self.documentStorageService = DocumentStorageService(database: database,
                                                             logger: usageLogService.documentLogger,
                                                             webservice: ukiBasedWebService,
                                                             login: session.login)

        self.identityDashboardService = IdentityDashboardService(session: session,
                                                                 settings: spiegelLocalSettingsStore,
                                                                 webservice: ukiBasedWebService,
                                                                 database: database,
                                                                 vaultItemsService: vaultItemsService,
                                                                 sharingKeysStore: sharingKeysStore,
                                                                 featureService: featureService,
                                                                 premiumService: premiumService,
                                                                 teamSpacesService: teamSpacesService,
                                                                 passwordEvaluator: appServices.passwordEvaluator,
                                                                 domainParser: appServices.domainParser,
                                                                 categorizer: appServices.categorizer,
                                                                 notificationService: notificationService,
                                                                 logger: logger[.identityDashboard])

        self.autofillService = AutofillService(vaultItemsService: vaultItemsService)

        self.todayExtensionCommunicator = AppTodayExtensionCommunicator(vaultItemsService: vaultItemsService,
                                                                        syncedSettings: syncedSettings,
                                                                        userSettings: spiegelUserSettings,
                                                                        anonymousDeviceId: appServices.globalSettings.anonymousDeviceId)
        
        self.watchAppCommunicator = AppWatchAppCommunicator(vaultItemsService: vaultItemsService)


        let aggregatedLogService = AggregatedLogService(vaultItemsService: vaultItemsService,
                                                        syncedSettings: syncedSettings,
                                                        usageLogService: usageLogService,
                                                        teamSpaceService: teamSpacesService,
                                                        identityDashboardService: identityDashboardService,
                                                        userSettings: spiegelUserSettings,
                                                        resetMasterPasswordService: resetMasterPasswordService,
                                                        autofillService: autofillService)
       
        self.darkWebMonitoringService = DarkWebMonitoringService(iconService: iconService,
                                                                 identityDashboardService: identityDashboardService,
                                                                 personalDataURLDecoder: appServices.personalDataURLDecoder,
                                                                 vaultItemsService: vaultItemsService,
                                                                 premiumService: premiumService,
                                                                 deepLinkingService: appServices.deepLinkingService,
                                                                 teamSpacesService: teamSpacesService,
                                                                 activityReporter: activityReporter,
                                                                 userSettings: spiegelUserSettings)
        
        self.dwmOnboardingService =  DWMOnboardingService(settings: dwmOnboardingSettings,
                                                          identityDashboardService: identityDashboardService,
                                                          personalDataURLDecoder: appServices.personalDataURLDecoder,
                                                          vaultItemsService: vaultItemsService,
                                                          darkWebMonitoringService: darkWebMonitoringService,
                                                          logger: logger[.dwmOnboarding])
        
        self.onboardingService = OnboardingService(loadingContext: loadingContext,
                                                   userSettings: spiegelUserSettings,
                                                   vaultItemsService: vaultItemsService,
                                                   dwmOnboardingSettings: dwmOnboardingSettings,
                                                   dwmOnboardingService: dwmOnboardingService,
                                                   syncedSettings: syncedSettings,
                                                   abTestService: authenticatedABTestingService,
                                                   lockService: lockService,
                                                   teamSpacesService: teamSpacesService,
                                                   featureService: featureService)
        
        let deviceInformationReporting = DeviceInformationReporting(webservice: legacyWebService,
                                                                    logger: logger[.session],
                                                                    resetMasterPasswordService: resetMasterPasswordService,
                                                                    userSettings: spiegelUserSettings,
                                                                    lockService: lockService,
                                                                    autofillService: autofillService,
                                                                    session: session)

        self.capabilityService = CapabilityService(featureService: featureService,
                                                   premiumService: premiumService)
        
        
        self.authenticatorAppCommunicator = AuthenticatorService(session: session,
                                                                 keychainService: appServices.keychainService,
                                                                 vaultItemService: vaultItemsService,
                                                                 accountAPIClient: AuthenticatedAccountAPIClient(apiClient: userDeviceAPIClient),
                                                                 authenticatorDatabase: appServices.authenticatorDatabaseService,
                                                                 lockSettings: spiegelLocalSettingsStore,
                                                                 logger: logger,
                                                                 loadingContext: loadingContext)

        self.vpnService = VPNService(networkEngine: userDeviceAPIClient,
                                     capabilityService: capabilityService,
                                     featureService: featureService,
                                     premiumService: premiumService,
                                     vaultItemsService: vaultItemsService,
                                     userSettings: spiegelUserSettings,
                                     usageLogService: usageLogService)

        self.activityReporter = SessionReporterService(activityReporter: activityReporter,
                                                       deviceInformation: deviceInformationReporting,
                                                       legacyAggregated: aggregatedLogService,
                                                       legacyUsage: usageLogService)
        
        
        
                self.toolsService = ToolsService(featureService: featureService,
                                         capabilityService: capabilityService)
        
        self.sharingLinkService = SharingLinkService(networkEngine: legacyWebService)

        await updateGlobalSessionEnvironment()
    }

    @MainActor
                            private func updateGlobalSessionEnvironment() {
        let activeEnvironment = GlobalEnvironmentValues.pushNewEnvironment()
        activeEnvironment.report = ReportAction(reporter: activityReporter)
        activeEnvironment.enabledAtLoginFeatures = featureService.enabledFeatures()
    }
}

typealias ViewModelFactory = SessionServicesContainer

extension SessionServicesContainer {
        var viewModelFactory: ViewModelFactory {
        return self
    }
}

extension VaultItemIconViewModel: SessionServicesInjecting { }
extension PasswordGeneratorViewModel: SessionServicesInjecting { }
extension PremiumAnnouncementsViewModel: SessionServicesInjecting { }
