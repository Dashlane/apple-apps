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
import AutofillKit
import CoreSync
import CoreSharing
import NotificationKit
import CoreUserTracking
import DashlaneAPI
import AuthenticatorKit
import CoreActivityLogs
import CorePasswords

struct SessionServicesContainer: DependenciesContainer {

    let loadingContext: SessionLoadingContext
    let session: Session
    let appServices: AppServicesContainer
    let iconService: IconServiceProtocol
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
    let authenticatorAppCommunicator: AuthenticatorAppCommunicationService
    let toolsService: ToolsService
    let sharingLinkService: SharingLinkService
    let activityReporter: SessionReporterService
    let otpDatabaseService: OTPDatabaseService
    let passwordEvaluator: PasswordEvaluatorProtocol
    let activityLogsService: ActivityLogsServiceProtocol
    let pasteboardService: PasteboardServiceProtocol

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

        self.premiumService = try await PremiumService(session: session,
                                                       userEncryptedSettings: spiegelUserEncryptedSettings,
                                                       legacyWebService: ukiBasedWebService,
                                                       apiClient: userDeviceAPIClient,
                                                       logger: logger[.session])

        self.activityLogsService = ActivityLogsService(premiumService: premiumService,
                                                 featureService: featureService,
                                                 apiClient: userDeviceAPIClient.teams.storeActivityLogs,
                                                 cryptoEngine: session.localCryptoEngine,
                                                 logger: appServices.rootLogger[.activityLogs])
        let sharingKeysStore = await SharingKeysStore(session: session, logger: appServices.rootLogger[.sync])

        self.sharingService = try await SharingService(session: session,
                                                       apiClient: userDeviceAPIClient.sharingUserdevice,
                                                       codeDecoder: appServices.regionInformationService,
                                                       personalDataURLDecoder: appServices.personalDataURLDecoder,
                                                       databaseDriver: databaseDriver,
                                                       sharingKeysStore: sharingKeysStore,
                                                       activityLogsService: activityLogsService,
                                                       logger: logger[.sharing],
                                                       activityReporter: activityReporter,
                                                       autoRevokeUsersWithInvalidProposeSignature: featureService.isEnabled(.autoRevokeInvalidSharingSignatureEnabled),
                                                       buildTarget: .app)

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
        
        self.authenticatedABTestingService = await AuthenticatedABTestingService(userSettings: spiegelUserSettings,
                                                                                 logger: logger[.abTesting],
                                                                                 login: session.login,
                                                                                 loadingContext: loadingContext,
                                                                                 authenticatedAPIClient: userDeviceAPIClient)

        self.notificationService = await SessionNotificationService(login: session.login,
                                                                    notificationService: appServices.notificationService,
                                                                    syncService: syncService,
                                                                    brazeService: appServices.brazeService,
                                                                    settings: spiegelUserSettings,
                                                                    webService: legacyWebService,
                                                                    logger: logger[.remoteNotifications])
        
        self.teamSpacesService = TeamSpacesService(database: database,
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
                                                         logger: logger[.session],
                                                         userDeviceApiClient: userDeviceAPIClient)

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
                                                         featureService: featureService,
                                                         activityLogsService: activityLogsService)

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
        self.pasteboardService = PasteboardService(userSettings: spiegelUserSettings)
        
        self.documentStorageService = DocumentStorageService(database: database,
                                                             webservice: ukiBasedWebService,
                                                             login: session.login)

        self.passwordEvaluator = featureService.isEnabled(.swiftZXCVBNEnabled) ? try PasswordEvaluator(useSwiftImplementationIfPossible: true) : appServices.passwordEvaluator
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
                                                   accountType: session.configuration.info.accountType,
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

        self.authenticatorAppCommunicator = AuthenticatorAppCommunicationService(session: session,
                                                                                 keychainService: appServices.keychainService,
                                                                                 vaultItemService: vaultItemsService,
                                                                                 userAPIClient: userDeviceAPIClient,
                                                                                 lockSettings: spiegelLocalSettingsStore,
                                                                                 logger: logger[.localCommunication],
                                                                                 loadingContext: loadingContext)

        self.vpnService = VPNService(networkEngine: userDeviceAPIClient,
                                     capabilityService: premiumService,
                                     featureService: featureService,
                                     premiumService: premiumService,
                                     vaultItemsService: vaultItemsService,
                                     userSettings: spiegelUserSettings)

        self.activityReporter = SessionReporterService(activityReporter: activityReporter,
                                                       loginMetricsReporter: appServices.loginMetricsReporter,
                                                       deviceInformation: deviceInformationReporting)

        self.otpDatabaseService = OTPDatabaseService(vaultItemsService: vaultItemsService,
                                                     activityReporter: activityReporter)

        
        
                self.toolsService = ToolsService(featureService: featureService,
                                         capabilityService: premiumService)
        
        self.sharingLinkService = SharingLinkService(networkEngine: legacyWebService)
        appServices.rootLogger[.session].info("Session Services loaded")
    }
             func postLoad() async {
        await updateGlobalSessionEnvironment()

        activityReporter.postLoadConfigure(using: self, loadingContext: loadingContext)
        configureBraze()
        authenticatedABTestingService.reportClientControlledTests()
                Task {
            if loadingContext.isAccountRecoveryLogin && session.configuration.info.accountType != .masterPassword {
                activityReporter.report(UserEvent.UseAccountRecoveryKey(flowStep: .complete))
                do {
                    try await accountRecoveryKeyService.deactivateAccountRecoveryKey(for: .keyUsed)
                } catch {
                    logger.fatal("Account Recovery Key auto disabling failed", error: error)
                }
            }
        }
        #if targetEnvironment(macCatalyst)
        appServices.safariExtensionService.currentSession = session
        #endif
    }

    @MainActor
                            private func updateGlobalSessionEnvironment() {
        let activeEnvironment = GlobalEnvironmentValues.pushNewEnvironment()
        activeEnvironment.report = ReportAction(reporter: activityReporter)
        activeEnvironment.enabledAtLoginFeatures = featureService.enabledFeatures()
    }

    private func configureBraze() {
        Task.detached(priority: .low) {
            await appServices.brazeService.registerLogin(session.login,
                                                         using: spiegelUserSettings,
                                                         webservice: legacyWebService,
                                                         featureService: featureService)
        }
    }
}

typealias ViewModelFactory = SessionServicesContainer

extension SessionServicesContainer {
        var viewModelFactory: ViewModelFactory {
        return self
    }
}

extension AddAttachmentButtonViewModel: SessionServicesInjecting { }
extension AttachmentRowViewModel: SessionServicesInjecting { }
extension AttachmentsListViewModel: SessionServicesInjecting { }
extension AttachmentsSectionViewModel: SessionServicesInjecting { }
extension PasswordGeneratorViewModel: SessionServicesInjecting { }
extension PremiumAnnouncementsViewModel: SessionServicesInjecting { }
extension VaultItemIconViewModel: SessionServicesInjecting { }

