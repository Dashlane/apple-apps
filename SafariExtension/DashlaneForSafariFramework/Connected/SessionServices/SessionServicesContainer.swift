import Foundation
import Combine
import CoreSession
import DashTypes
import CoreNetworking
import CoreUserTracking
import CorePersonalData
import CoreCategorizer
import SwiftTreats
import Logger
import DashlaneAppKit
import CoreSettings
import VaultKit
import CoreSync
import CoreSharing
import CoreFeature

struct SessionServicesContainer: DependenciesContainer {
    let session: CoreSession.Session
    let appServices: SafariExtensionAppServices
    
    let legacyWebService: LegacyWebService
    let userDeviceAPIClient: UserDeviceAPIClient
    
    let activityReporter: ActivityReporterProtocol
    
    let spiegelLocalSettingsStore: LocalSettingsStore
    let spiegelUserSettings: UserSettings
    let spiegelUserEncryptedSettings: UserEncryptedSettings
    let pasteboardService: PasteboardService
    let iconService: IconService
    
    let featureService: FeatureService
    let database: ApplicationDatabase
    let syncedSettings: SyncedSettingsService
    let usageLogService: UsageLogService
    let sharingService: SharedVaultHandling
    let syncService: SyncService
    let premiumService: PremiumService
    let teamSpacesService: TeamSpacesService
    let vaultItemsService: VaultItemsService
    let localAuthenticationInformationService: LocalAuthenticationInformationService

    init(appServices: SafariExtensionAppServices,
         session: CoreSession.Session) async throws {
        appServices.crashReporterService.associate(to: session.login)
        appServices.remoteLogger.configureReportedDeviceId(session.configuration.keys.serverAuthentication.deviceId)

        self.session = session
        self.appServices = appServices
        let logger = appServices.rootLogger
        logger[.session].info("Services loading begin")

        let ukiBasedWebService = LegacyWebServiceImpl(logger: logger[.network])
        ukiBasedWebService.configureAuthentication(usingLogin: session.login.email, uki: session.configuration.keys.serverAuthentication.uki.rawValue)
        self.legacyWebService = ukiBasedWebService
        userDeviceAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)

        self.activityReporter = UserTrackingSessionActivityReporter(appReporter: appServices.activityReporter,
                                                                    login: session.login,
                                                                    analyticsIdentifiers: session.configuration.keys.analyticsIds)
        
        self.featureService = await FeatureService(session: session,
                                                   apiClient: userDeviceAPIClient.features,
                                                   logger: logger[.features])
        
        self.iconService = IconService(session: session,
                                       webservice: ukiBasedWebService,
                                       logger: logger[.iconLibrary],
                                       target: .current)
        
        self.spiegelLocalSettingsStore = try appServices.spiegelSettingsManager.fetchOrCreateSettings(for: session)
        self.spiegelUserSettings = spiegelLocalSettingsStore.keyed(by: UserSettingsKey.self)
        self.spiegelUserEncryptedSettings = spiegelLocalSettingsStore.keyed(by: UserEncryptedSettingsKey.self)
        
        pasteboardService = PasteboardService(userSettings: spiegelUserSettings)
        
        
        let databaseDriver = try SQLiteDriver(session: session, target: .current)
        
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
                                                 target: .current)
                
        self.database = ApplicationDBStack(driver: databaseDriver,
                                           historyUserInfo: .init(session: session),
                                           codeDecoder: appServices.regionInformationService,
                                           personalDataURLDecoder: appServices.personalDataURLDecoder,
                                           logger: logger[.personalData])
        
        self.syncedSettings = try SyncedSettingsService(logger: logger[.personalData],
                                                              database: database)
    
        self.usageLogService = UsageLogService(logDirectory: try session.directory.storeURL(for: .usageLogs, in: .current),
                                               anonymousUserId: syncedSettings[\.anonymousUserId],
                                               webservice: appServices.nonAuthenticatedUKIBasedWebService,
                                               login: session.login,
                                               anonymousDeviceId: appServices.globalSettings.anonymousDeviceId,
                                               cryptoService: session.localCryptoEngine,
                                               logger: logger[.usageLogs])
        
        self.premiumService = try await PremiumService(session: session,
                                                       userEncryptedSettings: spiegelUserEncryptedSettings,
                                                       legacyWebService: ukiBasedWebService,
                                                       apiClient: userDeviceAPIClient,
                                                       logger: logger[.session],
                                                       usageLogService: usageLogService)
 
        self.teamSpacesService = TeamSpacesService(database: database,
                                                   usageLogService: usageLogService,
                                                   premiumService: premiumService,
                                                   syncedSettings: syncedSettings,
                                                   networkEngine: legacyWebService,
                                                   sharingService: sharingService,
                                                   logger: logger[.teamSpaces])

        
        self.vaultItemsService = await VaultItemsService(logger: logger[.personalData],
                                                         login: session.login,
                                                         context: .localLogin,
                                                         spotlightIndexer: nil,
                                                         userSettings: spiegelUserSettings,
                                                         categorizer: appServices.categorizer,
                                                         urlDecoder: appServices.personalDataURLDecoder,
                                                         sharingService: sharingService,
                                                         database: database,
                                                         teamSpacesService: teamSpacesService,
                                                         featureService: featureService)
        
        self.localAuthenticationInformationService = LocalAuthenticationInformationService(session: session,
                                                                                           premiumService: premiumService,
                                                                                           settings: spiegelLocalSettingsStore,
                                                                                           keychainService: appServices.keychainService)
    }
}

typealias ViewModelFactory = SessionServicesContainer

extension SessionServicesContainer {
        var viewModelFactory: ViewModelFactory {
        return self
    }
}
